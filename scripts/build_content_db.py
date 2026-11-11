
import csv
import sqlite3
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

CSV_PATH = (
    PROJECT_ROOT / "data" / "source" / "wordbloom_vocabulary.csv"
)

SCHEMA_PATH = PROJECT_ROOT / "scripts" / "schema.sql"
OUTPUT_PATH = PROJECT_ROOT / "data" / "content.db"


def build_database():
    # Validate the CSV before creating a database.
    result = subprocess.run(
        [sys.executable, str(PROJECT_ROOT / "scripts" / "validate_vocabulary.py")],
        check=False,
    )

    if result.returncode != 0:
        print("Database build stopped: CSV validation failed.")
        return False

    if not SCHEMA_PATH.exists():
        print("ERROR: schema.sql was not found.")
        return False

    # Build a temporary database first.
    temp_path = OUTPUT_PATH.with_suffix(".db.tmp")

    if temp_path.exists():
        temp_path.unlink()

    connection = sqlite3.connect(temp_path)

    try:
        connection.execute("PRAGMA foreign_keys = ON")
        connection.executescript(
            SCHEMA_PATH.read_text(encoding="utf-8")
        )

        with CSV_PATH.open(
            "r", encoding="utf-8-sig", newline=""
        ) as file:
            reader = csv.DictReader(file)

            for row in reader:
                if not row["id"].strip():
                    continue

                connection.execute(
                    """
                    INSERT INTO words (
                        id, word, part_of_speech, cefr_level,
                        definition, example, categories, status,
                        review_status, cefr_assignment, source,
                        review_notes
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        row["id"].strip(),
                        row["word"].strip(),
                        row["partOfSpeech"].strip(),
                        row["cefrLevel"].strip(),
                        row["definition"].strip(),
                        row["example"].strip(),
                        row["categories"].strip(),
                        row["status"].strip(),
                        row["reviewStatus"].strip(),
                        row["cefrAssignment"].strip(),
                        row["source"].strip(),
                        row["reviewNotes"].strip(),
                    ),
                )

                collections = [
                    value.strip()
                    for value in row["collections"].split(",")
                    if value.strip()
                ]

                for collection_id in collections:
                    connection.execute(
                        """
                        INSERT INTO word_collections (
                            word_id, collection_id
                        )
                        VALUES (?, ?)
                        """,
                        (row["id"].strip(), collection_id),
                    )

        connection.commit()

        word_count = connection.execute(
            "SELECT COUNT(*) FROM words"
        ).fetchone()[0]

        integrity = connection.execute(
            "PRAGMA integrity_check"
        ).fetchone()[0]

        if integrity != "ok":
            raise RuntimeError("SQLite integrity check failed.")

        if word_count == 0:
            raise RuntimeError("Database contains no words.")

        connection.close()

        # Replace the previous output only after a successful build.
        temp_path.replace(OUTPUT_PATH)

        print("\n=== WordBloom SQLite Build ===")
        print(f"Words imported: {word_count}")
        print(f"Database: {OUTPUT_PATH}")
        print("SQLite integrity: OK")
        print("DATABASE BUILD PASSED")

        return True

    except Exception as error:
        connection.close()

        if temp_path.exists():
            temp_path.unlink()

        print(f"DATABASE BUILD FAILED: {error}")
        return False


if __name__ == "__main__":
    raise SystemExit(0 if build_database() else 1)

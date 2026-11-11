
import csv
from collections import Counter
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = PROJECT_ROOT / "data" / "source" / "wordbloom_vocabulary.csv"

VALID_LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}
VALID_COLLECTIONS = {"most_common", "literary"}
VALID_REVIEW_STATUSES = {"needs_review", "in_review", "approved"}

REQUIRED_COLUMNS = {
    "id",
    "word",
    "partOfSpeech",
    "cefrLevel",
    "definition",
    "example",
    "categories",
    "collections",
    "reviewStatus",
}


def validate_vocabulary():
    if not CSV_PATH.exists():
        print(f"ERROR: CSV file not found: {CSV_PATH}")
        return False

    errors = []
    warnings = []
    words = []
    ids = set()
    word_keys = set()

    with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            print("ERROR: CSV has no header row.")
            return False

        missing_columns = REQUIRED_COLUMNS - set(reader.fieldnames)

        if missing_columns:
            print(f"ERROR: Missing columns: {sorted(missing_columns)}")
            return False

        for row_number, row in enumerate(reader, start=2):
            if None in row:
                errors.append(f"Row {row_number}: Too many CSV fields.")
                continue

            if any(value is None for value in row.values()):
                errors.append(f"Row {row_number}: Missing CSV fields.")
                continue

            if not any(value.strip() for value in row.values()):
                continue

            word_id = row["id"].strip()
            word = row["word"].strip()
            part_of_speech = row["partOfSpeech"].strip()
            level = row["cefrLevel"].strip()
            review_status = row["reviewStatus"].strip()

            for field in [
                "id",
                "word",
                "partOfSpeech",
                "cefrLevel",
                "definition",
                "example",
            ]:
                if not row[field].strip():
                    errors.append(
                        f"Row {row_number}: Missing required value: {field}"
                    )

            if word_id:
                if word_id in ids:
                    errors.append(
                        f"Row {row_number}: Duplicate ID: {word_id}"
                    )
                ids.add(word_id)

            if word and part_of_speech:
                word_key = (word.casefold(), part_of_speech.casefold())
                if word_key in word_keys:
                    warnings.append(
                        f"Row {row_number}: Possible duplicate word: "
                        f"{word} ({part_of_speech})"
                    )
                word_keys.add(word_key)

            if level not in VALID_LEVELS:
                errors.append(
                    f"Row {row_number}: Invalid CEFR level: {level}"
                )

            if review_status not in VALID_REVIEW_STATUSES:
                errors.append(
                    f"Row {row_number}: Invalid review status: {review_status}"
                )

            collections = [
                value.strip()
                for value in row["collections"].split(",")
                if value.strip()
            ]

            for collection in collections:
                if collection not in VALID_COLLECTIONS:
                    errors.append(
                        f"Row {row_number}: Invalid collection: {collection}"
                    )

            words.append(row)

    level_counts = Counter(row["cefrLevel"].strip() for row in words)

    print("\n=== WordBloom Vocabulary Validation ===")
    print(f"Total words: {len(words)}")

    for level in ["A1", "A2", "B1", "B2", "C1", "C2"]:
        print(f"{level}: {level_counts[level]}")

    print(f"\nErrors: {len(errors)}")
    print(f"Warnings: {len(warnings)}")

    for error in errors:
        print(f"ERROR: {error}")

    for warning in warnings:
        print(f"WARNING: {warning}")

    if errors:
        print("\nVALIDATION FAILED")
        return False

    print("\nVALIDATION PASSED")
    return True


if __name__ == "__main__":
    raise SystemExit(0 if validate_vocabulary() else 1)

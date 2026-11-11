
import sqlite3
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "data" / "content.db"

with sqlite3.connect(DB_PATH) as connection:
    connection.row_factory = sqlite3.Row

    print("\n=== WordBloom Database Test ===")

    # Count words by CEFR level.
    rows = connection.execute("""
        SELECT cefr_level, COUNT(*) AS total
        FROM words
        GROUP BY cefr_level
        ORDER BY
            CASE cefr_level
                WHEN 'A1' THEN 1
                WHEN 'A2' THEN 2
                WHEN 'B1' THEN 3
                WHEN 'B2' THEN 4
                WHEN 'C1' THEN 5
                WHEN 'C2' THEN 6
            END;
    """).fetchall()

    for row in rows:
        print(f"{row['cefr_level']}: {row['total']} words")

    # Preview some vocabulary.
    print("\nFirst 5 words:")

    rows = connection.execute("""
        SELECT word, cefr_level, part_of_speech
        FROM words
        ORDER BY id
        LIMIT 5;
    """).fetchall()

    for row in rows:
        print(
            f"{row['word']} | "
            f"{row['cefr_level']} | "
            f"{row['part_of_speech']}"
        )

    # Check collection relationships.
    print("\nCollections:")

    rows = connection.execute("""
        SELECT
            c.name,
            COUNT(wc.word_id) AS total_words
        FROM collections AS c
        LEFT JOIN word_collections AS wc
            ON c.id = wc.collection_id
        GROUP BY c.id, c.name;
    """).fetchall()

    for row in rows:
        print(f"{row['name']}: {row['total_words']} words")

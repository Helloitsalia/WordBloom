
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS words (
    id TEXT PRIMARY KEY,
    word TEXT NOT NULL,
    part_of_speech TEXT NOT NULL,
    cefr_level TEXT NOT NULL
        CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
    definition TEXT NOT NULL,
    example TEXT NOT NULL,
    categories TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'draft',
    review_status TEXT NOT NULL DEFAULT 'needs_review'
        CHECK (review_status IN (
            'needs_review', 'in_review', 'approved'
        )),
    cefr_assignment TEXT NOT NULL DEFAULT 'provisional',
    source TEXT NOT NULL DEFAULT '',
    review_notes TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS collections (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS word_collections (
    word_id TEXT NOT NULL,
    collection_id TEXT NOT NULL,

    PRIMARY KEY (word_id, collection_id),

    FOREIGN KEY (word_id)
        REFERENCES words(id),

    FOREIGN KEY (collection_id)
        REFERENCES collections(id)
);

INSERT OR IGNORE INTO collections (id, name)
VALUES
    ('most_common', 'Most Common Words'),
    ('literary', 'Beautiful & Literary Words');

CREATE INDEX IF NOT EXISTS idx_words_cefr
ON words(cefr_level);

CREATE INDEX IF NOT EXISTS idx_words_word
ON words(word);

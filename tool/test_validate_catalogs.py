"""Regression checks for the official MediX catalog safety gate."""

import copy
import unittest

from tool.validate_catalogs import validate_secondary


def snapshot(label: str, count: int = 2) -> dict:
    key = "effective_date" if label == "HZZO" else "published_date"
    return {
        "source": {"name": "Official example", key: "2026-10-01"},
        "record_count": count,
        "records": [
            {"id": str(i), "name": "Medicin", "active_ingredient": "Test"}
            for i in range(count)
        ],
    }


class CatalogValidatorTests(unittest.TestCase):
    def test_accepts_dated_catalogs(self):
        for label in ("HZZO", "HALMED prices"):
            with self.subTest(label=label):
                self.assertEqual(validate_secondary(snapshot(label), label, 2), 2)

    def test_rejects_inconsistent_record_count(self):
        value = snapshot("HZZO")
        value["record_count"] = 3
        with self.assertRaisesRegex(RuntimeError, "record_count"):
            validate_secondary(value, "HZZO", 2)

    def test_rejects_missing_source_name(self):
        value = snapshot("HZZO")
        value["source"]["name"] = ""
        with self.assertRaisesRegex(RuntimeError, "source name"):
            validate_secondary(value, "HZZO", 2)

    def test_rejects_missing_and_impossible_source_dates(self):
        for label in ("HZZO", "HALMED prices"):
            key = "effective_date" if label == "HZZO" else "published_date"
            for invalid in (None, "", "2026-02-30", "2026-10-1", "yesterday"):
                with self.subTest(label=label, invalid=invalid):
                    value = snapshot(label)
                    value["source"][key] = invalid
                    with self.assertRaises(RuntimeError):
                        validate_secondary(value, label, 2)

    def test_rejects_truncated_data(self):
        with self.assertRaisesRegex(RuntimeError, "below minimum"):
            validate_secondary(snapshot("HZZO", 1), "HZZO", 2)

    def test_rejects_nondictionary_records(self):
        value = snapshot("HZZO")
        value["records"][1] = "broken"
        with self.assertRaisesRegex(RuntimeError, "non-object"):
            validate_secondary(value, "HZZO", 2)

    def test_rejects_boolean_or_forged_counts(self):
        for count in (True, 2.0, "2"):
            with self.subTest(count=count):
                value = snapshot("HZZO")
                value["record_count"] = count
                with self.assertRaisesRegex(RuntimeError, "record_count"):
                    validate_secondary(value, "HZZO", 2)


if __name__ == "__main__":
    unittest.main()

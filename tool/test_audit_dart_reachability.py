import unittest

from tool.audit_dart_reachability import resolve_import


class DartReachabilityImportTests(unittest.TestCase):
    def test_plain_relative_import(self):
        self.assertEqual(
            resolve_import("lib/main.dart", "app/medix_app.dart"),
            "lib/app/medix_app.dart",
        )

    def test_parent_relative_import(self):
        self.assertEqual(
            resolve_import("lib/features/home/home_screen.dart", "../../models/medication.dart"),
            "lib/models/medication.dart",
        )

    def test_package_import(self):
        self.assertEqual(
            resolve_import("lib/main.dart", "package:medix/state/medix_state.dart"),
            "lib/state/medix_state.dart",
        )

    def test_external_import_is_excluded(self):
        self.assertIsNone(resolve_import("lib/main.dart", "package:flutter/material.dart"))


if __name__ == "__main__":
    unittest.main()

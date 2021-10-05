from unittest import TestCase

from lib import format_response, validate_body_content
from datetime import datetime, timedelta


class unitTest(TestCase):
    def test_birthday_response(self):
        self.assertEqual("Hello, oussama! Happy birthday!",
                         format_response(datetime.now(), "oussama"))

    def test_upcoming_birthday_response(self):
        self.assertEqual("Hello, oussama! Your birthday is in {} day(s)".format(
            5), format_response((datetime.today() + timedelta(days=5)), "oussama"))

    def test_not_valid_date(self):
        self.assertEqual({"valid_request": False,
                          "error_message": "dateOfBirth must be a valid date format : YYYY-MM-DD"}, validate_body_content("1992-10-40", "oussama"))

    def test_not_past_date(self):
        self.assertEqual({"valid_request": False,
                          "error_message": "YYYY-MM-DD must be a date before the today date"}, validate_body_content("2100-10-01", "oussama"))

    def test_not_alpha_username(self):
        self.assertEqual({"valid_request": False,
                          "error_message": "username must contain only letters"}, validate_body_content("1992-10-04", "oussama-1"))

    def test_valid_request_body(self):
        self.assertEqual({"valid_request": True},
                         validate_body_content("1992-10-04", "oussama"))

#!/usr/bin/python3
import os
import re
import csv
import yaml
from dateutil.parser import parse
from beancount.ingest import importer
from beancount.core import amount
from beancount.core import data
from beancount.core import flags
from beancount.core.number import D


class PNCBankImporter(importer.ImporterProtocol):
    def __init__(self, account, config_path):
        self.account = account
        self.config_path = config_path

    def name(self):
        return "PNCBankImporter"

    def identify(self, path):
        if re.match("pnc.*\.csv", os.path.basename(path.name)):
            with open(path.name, 'r') as f:
                line = f.readline()
                if line[:4] == 'Date':
                    return True
        return False

    def _read_accounts_yaml(self):
        with open(self.config_path, "r") as c:
            return yaml.safe_load(c)

    def _parse_desc(self, accounts, value):
        results = []
        for bucket in accounts.keys():
            for acct in accounts[bucket]:
                for t in accounts[bucket][acct]:
                    (desc, regex) = t.values()
                    if re.search(regex, value):
                        results.append((bucket + ":" + acct, desc))
        return results

    def extract(self, path):
        expenses = []
        entries = []
        accounts = []
        strip_spaces = re.compile(r"\W+")

        if os.path.isfile(self.config_path):
            accounts = self._read_accounts_yaml()

        with open(path.name, "r") as f:
            for index, row in enumerate(csv.DictReader(f)):
                # skips the header
                if index == 0:
                    continue

                meta = data.new_metadata(f.name, index)
                trans_date = parse(row["Date"]).date()
                trans_desc = strip_spaces.sub(" ", row["Description"]).lower().strip()
                trans_payee = ""
                trans_narr = trans_desc

                if row["Withdrawals"] != "":
                    amt = row["Withdrawals"][1:]
                    post_amt = amt
                    sec_post_amt = "-" + amt
                    post_acct = "Expenses:Unknown"
                else:
                    amt = row["Deposits"][1:]
                    post_amt = "-" + amt
                    sec_post_amt = amt
                    post_acct = "Income:Unknown"

                if len(accounts) > 0:
                    accts = self._parse_desc(accounts, trans_desc)
                    if len(accts) > 0:
                        first, *rest = accts
                        (post_acct, trans_payee) = first
                        trans_narr = trans_desc + "".join(rest)

                txn = data.Transaction(
                    meta=meta,
                    date=trans_date,
                    flag=flags.FLAG_OKAY,
                    payee=trans_payee,
                    narration=trans_narr,
                    tags=set(),
                    links=set(),
                    postings=[],
                )

                txn.postings.append(
                    data.Posting(
                        post_acct,
                        amount.Amount(D(post_amt), "USD"),
                        None,
                        None,
                        None,
                        None,
                    )
                )

                txn.postings.append(
                    data.Posting(
                        self.account,
                        amount.Amount(D(sec_post_amt), "USD"),
                        None,
                        None,
                        None,
                        None,
                    )
                )

                entries.append(txn)
        return entries

class PNCBankStatementImporter(importer.ImporterProtocol):
    def __init__(self, account, config_path):
        self.account = account
        self.config_path = config_path

    def name(self):
        return "PNCBankStatementImporter"

    def identify(self, path):
        if re.match("pnc.*\.csv", os.path.basename(path.name)):
            with open(path.name, 'r') as f:
                line = f.readline()
                if line[:4] == '0000':
                    return True
        return False

    def _read_accounts_yaml(self):
        with open(self.config_path, "r") as c:
            return yaml.safe_load(c)

    def _parse_desc(self, accounts, value):
        results = []
        for bucket in accounts.keys():
            for acct in accounts[bucket]:
                for t in accounts[bucket][acct]:
                    (desc, regex) = t.values()
                    if re.search(regex, value):
                        results.append((bucket + ":" + acct, desc))
        return results

    def extract(self, path):
        expenses = []
        entries = []
        accounts = []
        strip_spaces = re.compile(r"\W+")

        if os.path.isfile(self.config_path):
            accounts = self._read_accounts_yaml()

        with open(path.name, "r") as f:
            for index, row in enumerate(csv.reader(f)):
                # skips the header
                if index == 0:
                    continue

                meta = data.new_metadata(f.name, index)
                trans_date = parse(row[0]).date()
                trans_desc = strip_spaces.sub(" ", row[2]).lower().strip()
                trans_payee = ""
                trans_narr = trans_desc

                if row[5] != "CREDIT":
                    amt = row[1]
                    post_amt = amt
                    sec_post_amt = "-" + amt
                    post_acct = "Expenses:Unknown"
                else:
                    amt = row[1]
                    post_amt = "-" + amt
                    sec_post_amt = amt
                    post_acct = "Income:Unknown"

                if len(accounts) > 0:
                    accts = self._parse_desc(accounts, trans_desc)
                    if len(accts) > 0:
                        first, *rest = accts
                        (post_acct, trans_payee) = first
                        trans_narr = trans_desc + "".join(rest)

                txn = data.Transaction(
                    meta=meta,
                    date=trans_date,
                    flag=flags.FLAG_OKAY,
                    payee=trans_payee,
                    narration=trans_narr,
                    tags=set(),
                    links=set(),
                    postings=[],
                )

                txn.postings.append(
                    data.Posting(
                        post_acct,
                        amount.Amount(D(post_amt), "USD"),
                        None,
                        None,
                        None,
                        None,
                    )
                )

                txn.postings.append(
                    data.Posting(
                        self.account,
                        amount.Amount(D(sec_post_amt), "USD"),
                        None,
                        None,
                        None,
                        None,
                    )
                )

                entries.append(txn)
        return entries

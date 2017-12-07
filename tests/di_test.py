# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "data_ingest" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }

              appsvpc_id                  = "1234"
              opssubnet_cidr_block        = "1.2.3.0/24"
              data_ingest_cidr_block      = "10.1.6.0/24"
              data_pipe_apps_cidr_block   = "1.2.3.0/24"
              az                          = "eu-west-2a"
              name_prefix                 = "dq-"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_ingest_subnet(self):
        self.assertEqual(self.result['data_ingest']["aws_subnet.data_ingest"]["cidr_block"], "10.1.6.0/24")

    def test_name_prefix_data_ingest(self):
        self.assertEqual(self.result['data_ingest']["aws_subnet.data_ingest"]["tags.Name"], "dq-apps-data-ingest-subnet")

    def test_name_prefix_di_db(self):
        self.assertEqual(self.result['data_ingest']["aws_security_group.di_db"]["tags.Name"], "dq-apps-data-ingest-db-sg")

    def test_name_prefix_di_web(self):
        self.assertEqual(self.result['data_ingest']["aws_security_group.di_web"]["tags.Name"], "dq-apps-data-ingest-web-sg")

if __name__ == '__main__':
    unittest.main()

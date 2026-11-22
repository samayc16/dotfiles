"""OS-release parsing and distro → family mapping."""

import unittest

from installer.host import Host, family, parse_os_release

UBUNTU = 'NAME="Ubuntu"\nID=ubuntu\nID_LIKE=debian\nPRETTY_NAME="Ubuntu 24.04.1 LTS"\n'
ROCKY = 'ID="rocky"\nID_LIKE="rhel centos fedora"\nPRETTY_NAME="Rocky Linux 9.4 (Blue Onyx)"\n'


class ParseOsRelease(unittest.TestCase):
    def test_quotes_and_comments(self) -> None:
        values = parse_os_release('# comment\nID="arch"\nNAME=\'Arch Linux\'\n\nBAD LINE\n')
        self.assertEqual(values, {"ID": "arch", "NAME": "Arch Linux"})

    def test_ubuntu(self) -> None:
        values = parse_os_release(UBUNTU)
        self.assertEqual(family(values["ID"], values["ID_LIKE"]), "debian")

    def test_rocky_uses_id_like(self) -> None:
        values = parse_os_release(ROCKY)
        self.assertEqual(family(values["ID"], values["ID_LIKE"]), "rhel")


class Family(unittest.TestCase):
    def test_known(self) -> None:
        cases = {("arch", ""): "arch", ("fedora", ""): "rhel", ("opensuse-tumbleweed", "suse opensuse"): "suse",
                 ("linuxmint", "ubuntu debian"): "debian", ("amzn", "centos rhel fedora"): "rhel"}
        for (os_id, like), expected in cases.items():
            with self.subTest(os_id=os_id):
                self.assertEqual(family(os_id, like), expected)

    def test_unknown_is_generic_linux(self) -> None:
        self.assertEqual(family("nixos", ""), "linux")


class Privileges(unittest.TestCase):
    def test_can_install_system(self) -> None:
        mac = Host("macos", "macOS", "arm64", False, False, False)
        locked = Host("rhel", "Rocky", "x86_64", False, False, False)
        sudoer = Host("debian", "Ubuntu", "x86_64", False, True, False)
        self.assertTrue(mac.can_install_system)
        self.assertFalse(locked.can_install_system)
        self.assertTrue(sudoer.can_install_system)
        self.assertTrue(locked.is_linux and not locked.is_mac)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Replace home/login navigation with AppNavigation.* for go_router migration."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

# (regex, replacement lambda or str)
REPLACERS = [
    # pushReplacement -> SpareHome (const or not)
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?SpareHomeScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goSpareHome(context);",
    ),
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopHomeScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goShopHome(context);",
    ),
    # pushAndRemoveUntil -> SpareHome
    (
        re.compile(
            r"Navigator\.pushAndRemoveUntil\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?SpareHomeScreen\(\)\),\s*"
            r"\(route\)\s*=>\s*false,\s*\);"
        ),
        "AppNavigation.goSpareHome(context);",
    ),
    (
        re.compile(
            r"Navigator\.pushAndRemoveUntil\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopHomeScreen\(\)\),\s*"
            r"\(route\)\s*=>\s*false,\s*\);"
        ),
        "AppNavigation.goShopHome(context);",
    ),
    # Logout -> login
    (
        re.compile(
            r"Navigator\.pushAndRemoveUntil\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?SpareLoginScreen\(\)\),\s*"
            r"\(route\)\s*=>\s*false,\s*\);"
        ),
        "AppNavigation.goSpareLogin(context);",
    ),
    (
        re.compile(
            r"Navigator\.pushAndRemoveUntil\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopLoginScreen\(\)\),\s*"
            r"\(route\)\s*=>\s*false,\s*\);"
        ),
        "AppNavigation.goShopLogin(context);",
    ),
    # Tab roots: pushReplacement -> shell routes (spare)
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?PaymentScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goSpareMainTab(context, 1);",
    ),
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?FavoritesScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goSpareMainTab(context, 2);",
    ),
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ProfileScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goSpareMainTab(context, 3);",
    ),
    # Tab roots: pushReplacement -> shell routes (shop)
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopPaymentScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goShopMainTab(context, 1);",
    ),
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopFavoritesScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goShopMainTab(context, 2);",
    ),
    (
        re.compile(
            r"Navigator\.pushReplacement\(\s*context,\s*"
            r"MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?ShopProfileScreen\(\)\),\s*\);"
        ),
        "AppNavigation.goShopMainTab(context, 3);",
    ),
]

IMPORT_LINE = "import '../../core/router/app_navigation.dart';\n"
IMPORT_LINE_SHOP = "import '../../core/router/app_navigation.dart';\n"
IMPORT_LINE_UTIL = "import '../core/router/app_navigation.dart';\n"
IMPORT_LINE_WIDGET = "import '../core/router/app_navigation.dart';\n"


def rel_import_for(path: Path) -> str:
    rel = path.relative_to(ROOT)
    depth = len(rel.parts) - 1
    prefix = "../" * depth
    return f"import '{prefix}core/router/app_navigation.dart';\n"


def ensure_import(content: str, path: Path) -> str:
    if "app_navigation.dart" in content:
        return content
    line = rel_import_for(path)
    # After last package import or first line
    lines = content.splitlines(keepends=True)
    insert_at = 0
    for i, ln in enumerate(lines):
        if ln.startswith("import "):
            insert_at = i + 1
    lines.insert(insert_at, line)
    return "".join(lines)


def simplify_bottom_nav_ontap(content: str, path: Path) -> str:
    """Collapse setState + 4-case switch to go*MainTab when cases are all routed."""
    is_shop = "screens/shop/" in str(path)
    home = "goShopHome" if is_shop else "goSpareHome"
    main = "goShopMainTab" if is_shop else "goSpareMainTab"
    pat = re.compile(
        rf"(\s*)onTap: \(index\) \{{\n"
        rf"\s*setState\(\(\) \{{\n"
        rf"\s*_currentNavIndex = index;\n"
        rf"\s*\}}\);\n"
        rf"(?:\s*\n)?"
        rf"(?:\s*//[^\n]+\n)?"
        rf"\s*switch \(index\) \{{\n"
        rf"\s*case 0:(?:[^\n]*\n)*?\s*AppNavigation\.{re.escape(home)}\(context\);\n\s*break;\n"
        rf"\s*case 1:(?:[^\n]*\n)*?\s*AppNavigation\.{re.escape(main)}\(context, 1\);\n\s*break;\n"
        rf"\s*case 2:(?:[^\n]*\n)*?\s*AppNavigation\.{re.escape(main)}\(context, 2\);\n\s*break;\n"
        rf"\s*case 3:(?:[^\n]*\n)*?\s*AppNavigation\.{re.escape(main)}\(context, 3\);\n\s*break;\n"
        rf"\s*\}}\n"
        rf"\s*\}},",
        re.MULTILINE | re.DOTALL,
    )

    def repl(m: re.Match[str]) -> str:
        return f"{m.group(1)}onTap: (index) => AppNavigation.{main}(context, index),"

    return pat.sub(repl, content)


def fix_empty_tab_case(content: str, path: Path) -> str:
    """Turn `case N: // ... break;` stubs into go*MainTab (e.g. // 현재 화면)."""
    is_shop = "screens/shop/" in str(path)
    fn = "goShopMainTab" if is_shop else "goSpareMainTab"
    for idx in (1, 2, 3):
        content = re.sub(
            rf"case {idx}:\s*//[^\n]*\n(\s*)break;",
            lambda m, i=idx, f=fn: f"case {i}:\n{m.group(1)}AppNavigation.{f}(context, {i});\n{m.group(1)}break;",
            content,
        )
    return content


def main():
    for path in sorted(ROOT.rglob("*.dart")):
        text = path.read_text(encoding="utf-8")
        orig = text
        for pat, repl in REPLACERS:
            text = pat.sub(repl, text)
        text = fix_empty_tab_case(text, path)
        text = simplify_bottom_nav_ontap(text, path)
        if text != orig:
            text = ensure_import(text, path)
            path.write_text(text, encoding="utf-8")
            print("updated", path.relative_to(ROOT.parent))


if __name__ == "__main__":
    main()

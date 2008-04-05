use inc::Module::Install;
name 'Test-Declare';
all_from 'lib/Test/Declare.pm';

use_test_base;
build_requires 'Test::More';
build_requires 'Test::Builder';

auto_include;
WriteAll;

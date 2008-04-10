use inc::Module::Install;
name 'Test-Declare';
all_from 'lib/Test/Declare.pm';

requires 'Exporter';
requires 'PPI';
requires 'Test::Deep';
requires 'Test::Exception';
requires 'IO::Scalar';

use_test_base;
build_requires 'Test::More';
build_requires 'Test::Builder';
build_requires 'Test::Perl::Critic';

auto_include;
WriteAll;

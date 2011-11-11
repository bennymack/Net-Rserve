use inc::Module::Install;

# Define metadata
name           'Net-Rserve';
all_from       'lib/Net/Rserve.pm';

# Specific dependencies
#requires       'File::Spec'              => '0.80';
test_requires  'Test::Class'              => '0';
test_requires  'Test::Exception'          => '0';
#recommends     'Text::CSV_XS'             => '0.50';
#no_index       'directory'   => 'demos';
#install_script 'myscript';
tests           't/Net/*Test.pm';

WriteAll;


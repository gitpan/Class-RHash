use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Class::RHash',
    VERSION_FROM  => 'RHash.pm',
    PREREQ_PM     => { 
        'Hash::Util' => '0.05',
	'NEXT'       => '0.60',
    },
    ABSTRACT_FROM => 'RHash.pm',
    AUTHOR        => 'Ben Morrow <Class-RHash@morrow.me.uk>',
);


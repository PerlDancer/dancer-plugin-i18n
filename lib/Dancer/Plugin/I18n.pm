package Dancer::Plugin::I18n;

use strict;
use warnings;

use Dancer::Plugin;
use Dancer ':syntax';

use I18N::LangTags;
use I18N::LangTags::Detect;

our $VERSION = '0.01';

my @languages;
my $i18n_package;

add_hook(
    before => sub {
        my $request = request;
        @languages = ('en');
        push @languages,
          I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs(
                scalar $request->accept_language
            )
          );

        my $app = setting('appname');
        if (!$app) {
            die "Impossible to find your application name; please set the appname in your configuration";
        }
        $i18n_package = $app . "::I18N";
        eval "package $i18n_package; use base 'Locale::Maketext'; 1;";
        die "Impossible to load I18N plugin : $@" if $@;
    }
);

add_hook(
    before_template => sub {
        my $tokens = shift;
        $tokens->{l}         = sub { _localize(@_) };
        $tokens->{languages} = sub { _languages(@_) };
    },
);

register languages => sub { _languages(@_); };
register l         => sub { _localize(@_); };

sub _languages {
    my @lang = shift;

    return $languages[0] unless @lang;
    unshift @languages, @lang;
    return;
}

sub _localize {
    if ($i18n_package && (my $h = $i18n_package->get_handle(@languages))) {
        return $h->maketext(@_);
    }
    else {
        return join '', @_;
    }
}

register_plugin;

1;
__END__

=head1 NAME

Dancer::Plugin::I18n - Intenationalization for Dancer

=head1 SYNOPSIS

    package myapp::I18N::fr;
    use base 'myapp::I18N';
    our %Lexicon = ( hello => 'bonjour' );
    1;

    package myapp;
    use Dancer;
    use Dancer::Plugin::I18n;
    get '/' => sub { template 'index' };

    # index.tt
    hello in <% languages %> => <% l('hello') %>
    # or
    <% languages('fr') %>This is an <% l('hello') %>

=head1 DESCRIPTION

Dancer::Plugin::I18n add L<Locale::Maketext> to your L<Dancer> application

=head1 METHODS

=head2 languages

=head2 l

=head1 AUTHOR

franck cuny E<lt>franck@lumberjaph.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

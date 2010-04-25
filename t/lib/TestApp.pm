package TestApp;

use Dancer;
use Dancer::Plugin::I18n;

get '/' => sub { template 'index'; };

package TestApp::I18N::de;
use base 'TestApp::I18N';
our %Lexicon = ( hello => 'hallo' );

package TestApp::I18N::fr;
use base 'TestApp::I18N';
our %Lexicon = ( hello => 'bonjour' );

1;

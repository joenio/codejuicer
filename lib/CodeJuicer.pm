package CodeJuicer;
use Modern::Perl;

use File::Share ':all';
our $SHAREDIR = dist_dir(__PACKAGE__);

use Gearman::Client;
our $GEARMAN_PORT = 4730;
our $gearman = Gearman::Client->new;
$gearman->job_servers("127.0.0.1:$GEARMAN_PORT");

1;

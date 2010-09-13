#!/usr/bin/perl
use Curses;
use Term::ReadKey;

open(IN,"</dev/tty");
*OUT = *IN;
initscr();
start_color;
init_pair(1,COLOR_WHITE,COLOR_BLUE);
init_pair(2,COLOR_CYAN,COLOR_BLUE);
init_pair(3,COLOR_CYAN,COLOR_BLACK);
init_pair(4,COLOR_RED,COLOR_BLACK);
init_pair(5,COLOR_WHITE,COLOR_BLACK);
$twirl[0] = "|"; $twirl[1] = "/"; 
$twirl[2] = "-"; $twirl[3] = "\\"; 
$twirl[4] = "|"; $twirl[5] = "/";
$twirl[6] = "-"; $twirl[7] = "\\"; 
my $win = Curses->new  or die "Can't get new window\n";
$win2 = $win->new(28,80,0,0);
$fromname = "NULL";
$fromaddr = "NULL";
$toname = "NULL";
$subject = "NULL";
$win2->scrollok(1);
noecho();
&infobar();
&inputbox();
$win->move(29,13);
$cpos = 13;
$tpos = 0;
$win->refresh;
ReadMode 4, IN;
$inputUser = "";
$in = \*IN;
while(uc($inputUser) ne "q") {
  $win->attrset(0);
  $win->attron(COLOR_PAIR(2));
  $win->addstr(28, 1, "[");
  $win->attrset(0);
  $win->attron(COLOR_PAIR(1)|A_BOLD);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  if (length($hour) eq 1) { $hour = "0".$hour; }
  if (length($min) eq 1) { $min = "0".$min; }
  $strnow = $hour.":".$min;
  $win->addstr(28, 2, $strnow);
  $win->attrset(0);
  $win->attron(COLOR_PAIR(2));
  $win->addstr(28, 7, "]");
  $win->attrset(0);
  $win->move(29,$cpos);    
  $inputUser = ReadKey(-1,$in);
  if (ord($inputUser) eq 27) {
    $nextkey = ReadKey(-1,$in);
    $nextkey = ReadKey(-1,$in);
  } elsif (ord($inputUser) eq 13) {
    $cmdok = 0;
    $win->addstr(29, 13, " " x 67);
    if (uc($commandstring) eq "QUIT") {
      $win->refresh;
      endwin();
      exit;
    } elsif (uc(substr($commandstring,0,4)) eq "EXIT") {
      $win->refresh;
      endwin();
      exit;
    } elsif (uc(substr($commandstring,0,4)) eq "HELP") {
      &addhelp("The following is a list of commands that EmailBlast understands:");
      &addhelp("-" x 71);
      &addhelpitem("The set command let's you set specific variables in","SET");
      &addhelpitem("EmailBlast such as the from name, to name etc...For","");
      &addhelpitem("more info on SET, enter the command SET at the prompt.","");
      &addhelp("-" x 71);
      &addhelpitem("LOAD will load a text file of e-mails into memory.","LOAD");
      &addhelpitem("The text file format is one e-mail per line. LOAD","");
      &addhelpitem("automatically parses the list for duplicates and","");
      &addhelpitem("removes any e-mail that is syntax-wise incorrect.","");
      &addhelp("-" x 71);
      &addhelpitem("BODY will load a text file into memory which will","BODY");
      &addhelpitem("be used as the e-mails contents. The file can be ","");
      &addhelpitem("in plain text or be in HTML.","");
      &addhelp("-" x 71);
      &addhelpitem("Once you have set all your required environments","SEND");
      &addhelpitem("and have loaded a database file into memory, you","");
      &addhelpitem("can issue the SEND command. This will send the","");
      &addhelpitem("selected text file to each e-mail address in the list.","");
      $cmdok = 1;
    } elsif (uc(substr($commandstring,0,4)) eq "SEND") {
      $win->attrset(0);
      $win->attron(COLOR_PAIR(2));
      $win->addstr(28, 7, "]");
      $win->addstr(28, 61, "[");
      $win->addstr(28, 72, "]");
      $win->attrset(0);
      $win->attron(COLOR_PAIR(1)|A_BOLD);
      $win->addstr(28, 74, "  0%");
      $win->attrset(0);
      $win->refresh;
      addmessage("Sending e-mails...please wait...");
      $lindex = 0;
      $Twirlcount = 0;
      $Twirlnum = 0;
      foreach $to_addr (@ValidEmails) {
        $Twirlcount++;
        if ($Twirlcount eq 50) {
          $win->attron(COLOR_PAIR(3)|A_BOLD);
          $win->addstr(29, 13, $twirl[$Twirlnum]);
          $win->attrset(0);
          $win->refresh();
          $Twirlnum++;
          if ($Twirlnum eq 8) { $Twirlnum = 0; }
          $Twirlcount = 0;
        }
        $lindex++;
        $perce = (($lindex * 100) / $ETotalCount);
        $win->attrset(0);
        $win->attron(COLOR_PAIR(1)|A_BOLD);
        if ($perce > 0) {
          $win->addstr(28, 62, "*");
        }
        if ($perce > 10) {
          $win->addstr(28, 63, "*");
        }
        if ($perce > 20) {
          $win->addstr(28, 64, "*");
        }
        if ($perce > 30) {
          $win->addstr(28, 65, "*");
        }
        if ($perce > 40) {
          $win->addstr(28, 66, "*");
        }
        if ($perce > 50) {
          $win->addstr(28, 67, "*");
        }
        if ($perce > 60) {
          $win->addstr(28, 68, "*");
        }
        if ($perce > 70) {
          $win->addstr(28, 69, "*");
        }
        if ($perce > 80) {
          $win->addstr(28, 70, "*");
        }
        if ($perce > 90) {
          $win->addstr(28, 71, "*");
        }
        ($perce,$junker) = split(/\./, $perce);
        if (length($perce) eq 1) {
          $perce = "  $perce";
        } elsif (length($perce) eq 2) {
          $perce = " $perce";
        }
        $win->addstr(28, 74, "$perce%");
        $win->attrset(0);
        $win->refresh;
        $to_addr =~ s/\n//gi;
        $to_addr =~ s/\r//gi;
        open (SENDMAIL, "|/usr/sbin/sendmail -t");
          print SENDMAIL <<"EOF";
From: $fromname <$fromaddr>
Subject: $subject
To: $toname <$to_addr>
MIME-Version: 1.0
Content-Type: TEXT/HTML; charset=US-ASCII

$BodyContents

EOF
        close (SENDMAIL);
      }
      $win->addstr(29, 13, " " x 67);
      addmessage("Done.");
      $win->attron(COLOR_PAIR(1)|A_BOLD);
      $win->addstr(28, 62, "**********");
      $win->addstr(28, 74, "100%");
      $win->attrset(0);
      $cmdok = 1;
    } elsif (uc(substr($commandstring,0,4)) eq "BODY") {
      if ( -e substr($commandstring,5) ) {
        $BodyFile = substr($commandstring,5);
        $BodyContents = `cat $BodyFile`;
        addmessage("Added $BodyFile as the e-mail contents.");
      } else {
        adderror("Unable to locate file: ".substr($commandstring,5));
      }
      $cmdok = 1;      
    } elsif (uc(substr($commandstring,0,4)) eq "LOAD") {
      if ( -e substr($commandstring,5) ) {
        addmessage("Loading e-mail database from ".substr($commandstring,5));
        open (READ,substr($commandstring,5));
          @InputFile = <READ>;
        close (READ);
        addmessage("Parsing e-mails for duplicates and removing invalid e-mails");
        $ETotalCount = 0;
        $EValidCount = 0;
        $Twirlcount = 0;
        $Twirlnum = 0;
        foreach $EmailAddress (@InputFile) {
          $Twirlcount++;
          if ($Twirlcount eq 50) {
            $win->attron(COLOR_PAIR(3)|A_BOLD);
            $win->addstr(29, 13, $twirl[$Twirlnum]);
            $win->attrset(0);
            $win->refresh();
            $Twirlnum++;
            if ($Twirlnum eq 8) { $Twirlnum = 0; }
            $Twirlcount = 0;
          }
          $ETotalCount++;
          $EmailAddress =~ s/\n//gi;
          $EmailAddress =~ s/\r//gi;
          $EmailAddress =~ s/\ //gi;
          $EmailAddress =~ /^([\w\-\.\!\%\+]+\@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+)$/;
          $EmailReturn = $1;
          if (!($EmailReturn)) {
            if (!($EmailCheck{$EmailAddress})) {
              $EmailCheck{$EmailAddress} = $EmailAddress;
              $EmailAddress =~ /^([\w]+\@+.)/;
              if ($1) {
                $EmailFix = $EmailAddress;
                $Checked = 0;
                if (uc(substr($EmailFix,length($EmailFix) - 3, 3)) eq "AOL") {
                  $EmailFix.=".com";
                  $EmailFix =~ /^([\w\-\.\!\%\+]+\@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+)$/;
                  if ($1) {
                    push(@ValidEmails, $EmailAddress);
                    $EValidCount++;
                  }
                  $Checked = 1;
                }
                if (uc(substr($EmailFix,length($EmailFix) - 5, 5)) eq "YAHOO") {
                  $EmailFix.=".com";
                  $EmailFix =~ /^([\w\-\.\!\%\+]+\@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+)$/;
                  if ($1) {
                    push(@ValidEmails, $EmailAddress);
                    $EValidCount++;
                  }
                  $Checked = 1;
                }
                if (uc(substr($EmailFix,length($EmailFix) - 7, 7)) eq "HOTMAIL") {
                  $EmailFix.=".com";
                  $EmailFix =~ /^([\w\-\.\!\%\+]+\@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+)$/;
                  if ($1) {
                    push(@ValidEmails, $EmailAddress);
                    $EValidCount++;
                  }
                  $Checked = 1;
                }
                if (uc(substr($EmailFix,length($EmailFix) - 9, 9)) eq "EARTHLINK") {
                  $EmailFix.=".com";
                  $EmailFix =~ /^([\w\-\.\!\%\+]+\@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+)$/;
                  if ($1) {
                    push(@ValidEmails, $EmailAddress);
                    $EValidCount++;
                  }
                  $Checked = 1;
                }
              }
            }
          } else {
            if (!($EmailCheck{$EmailAddress})) {
              $EmailCheck{$EmailAddress} = $EmailAddress;
              push(@ValidEmails, $EmailAddress);
              $EValidCount++;
            }
          }
        }
        $win->addstr(29, 13, " " x 67);
        addmessage("Total lines parsed: $ETotalCount");
        addmessage("Valid count: $EValidCount");
        addmessage("Invalid count: ".($ETotalCount - $EValidCount));
      } else {
        adderror("Unable to locate file: ".substr($commandstring,5));
      }
      $cmdok = 1;
    } elsif (uc(substr($commandstring,0,3)) eq "SET") {
      if (uc(substr($commandstring,4,9)) eq "FROM NAME") {
        $fromname = substr($commandstring,14);
        &addaction("FROM NAME",$fromname);
        $cmdok = 1;
      } elsif (uc(substr($commandstring,4,12)) eq "FROM ADDRESS") {
        $fromaddr = substr($commandstring,17);
        &addaction("FROM ADDRESS",$fromaddr);
        $cmdok = 1;
      } elsif (uc(substr($commandstring,4,7)) eq "TO NAME") {
        $toname = substr($commandstring,12);
        &addaction("TO NAME",$toname);
        $cmdok = 1;
      } elsif (uc(substr($commandstring,4,7)) eq "SUBJECT") {
        $subject = substr($commandstring,12);
        &addaction("SUBJECT",$subject);
        $cmdok = 1;
      } else {
        &addhelp("SET requires the function name to set, and the new value");
        &addhelp("to be set. Below is a list of function names and their");
        &addhelp("current values:");
        &addhelpitem("$fromname","FROM NAME");
        &addhelpitem("$fromaddr","FROM ADDRESS");
        &addhelpitem("$toname","TO NAME");
        &addhelpitem("$subject","SUBJECT");
        $cmdok = 1;
      }
    }
    if ($cmdok eq 0) {
      if (length($commandstring) ne 0) {
        &adderror("Unknown command. Please try using HELP.");
      }
    }
    $cpos = 13;
    $win->move(29,$cpos);
    $commandstring = "";
  } elsif (ord($inputUser) eq 127) {
    $cpos-- unless $cpos eq 13;
    $win->addstr(29, $cpos, " ");
    $win->move(29,$cpos);
    $commandstring = substr($commandstring,0,length($commandstring) - 1) unless length($commandstring) eq 0;
  } else {
    if (length($inputUser) ne 0) {
      $win->addstr(29, $cpos, $inputUser);
      $cpos++;
      $win->move(29,$cpos);
      $commandstring.=$inputUser;
    }
  }
  1;
  $win->refresh;
};
endwin();

sub addaction() {
  ($acttype, $actstring) = @_;
  if ($tpos eq 28) {
    $win2->scroll();
    $tpos--;
  }
  $win2->attron(COLOR_PAIR(3)|A_BOLD);
  $win2->addstr($tpos, 0, "[");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(3));
  $win2->addstr($tpos, 1, "SET");
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, 4, "]");
  $win2->attrset(0);
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, 6, $acttype);
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, 7 + length($acttype), "set to value \"");
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, (21 + length($acttype)), $actstring);
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, (21 + length($acttype) + length($actstring)),"\"");
  $win2->attrset(0);
  $win2->refresh;
  if ($tpos ne 28) {
    $tpos++;
  }
}

sub adderror() {
  ($errstring) = @_;
  if ($tpos > 27) {
    $win2->scroll();
    $tpos--;
  }
  $win2->attron(COLOR_PAIR(4));
  $win2->addstr($tpos, 0, "[");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(4)|A_BOLD);
  $win2->addstr($tpos, 1, "ERROR");
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, 6, "]");
  $win2->attrset(0);
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, 8, $errstring);
  $win2->attrset(0);
  $win2->refresh;
  if ($tpos ne 28) {
    $tpos++;
  }
}

sub addhelp() {
  ($helpstring) = @_;
  if ($tpos > 27) {
    $win2->scroll();
    $tpos--;
  }
  $win2->attron(COLOR_PAIR(5));
  $win2->addstr($tpos, 0, "[");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(5)|A_BOLD);
  $win2->addstr($tpos, 1, "HELP");
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, 5, "]");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(3));
  $win2->addstr($tpos, 7, $helpstring);
  $win2->attrset(0);
  $win2->refresh;
  if ($tpos ne 28) {
    $tpos++;
  }
}

sub addhelpitem() {
  ($helpstring, $helpitem) = @_;
  if ($tpos > 27) {
    $win2->scroll();
    $tpos--;
  }
  $win2->attron(COLOR_PAIR(5));
  $win2->addstr($tpos, 0, "[");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(5)|A_BOLD);
  $win2->addstr($tpos, 1, "HELP");
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, 5, "]");
  $win2->attrset(0);
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, 8, $helpitem);
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(3));
  $win2->addstr($tpos, 23, $helpstring);
  $win2->attrset(0);
  $win2->refresh;
  if ($tpos ne 28) {
    $tpos++;
  }
}

sub addmessage() {
  ($msgstring) = @_;
  if ($tpos > 27) {
    $win2->scroll();
    $tpos--;
  }
  $win2->attron(COLOR_PAIR(3));
  $win2->addstr($tpos, 0, "[");
  $win2->attrset(0);
  $win2->attron(COLOR_PAIR(3)|A_BOLD);
  $win2->addstr($tpos, 1, "MSG");
  $win2->attroff(A_BOLD);
  $win2->addstr($tpos, 4, "]");
  $win2->attrset(0);
  $win2->attron(A_BOLD);
  $win2->addstr($tpos, 6, $msgstring);
  $win2->attrset(0);
  $win2->refresh;
  if ($tpos ne 28) {
    $tpos++;
  }
}

sub inputbox() {
  $win->attron(COLOR_PAIR(3)|A_BOLD);
  $win->addstr(29, 0, "[");
  $win->attrset(0);
  $win->attron(A_BOLD);
  $win->addstr(29, 1, "EmailBlast");
  $win->attron(COLOR_PAIR(3));
  $win->addstr(29, 11, "]");
  $win->attrset(0);
  $win->refresh;
}

sub infobar() {
  $win->attron(COLOR_PAIR(1)|A_BOLD);
  $win->addstr(28, 0, " " x 80);
  $win->attrset(0);
  $win->attron(COLOR_PAIR(2));
  $win->addstr(28, 1, "[");
  $win->attrset(0);
  $win->attron(COLOR_PAIR(1)|A_BOLD);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  if (length($hour) eq 1) { $hour = "0".$hour; }
  if (length($min) eq 1) { $min = "0".$min; }
  $strnow = $hour.":".$min;
  $win->addstr(28, 2, $strnow);
  $win->attrset(0);
  $win->attron(COLOR_PAIR(2));
  $win->addstr(28, 7, "]");
  $win->attrset(0);
  $win->refresh();
}
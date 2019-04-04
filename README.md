# config_files

To install on linux, pull this to ~/Documents/git/config_files
the scripts are dumb af, they won't work anywhere else.
Then from the root of this repo, run ./linux/install_stff.sh
currently the scripts print a lot.

Once it is done, log out and back in.

One thing to note when working with ROS is that things that
you install to python normally might not be available in ROS
For example, flake. So it is best to source all of the ros stuff
before opening your text editor. You may find that you also need
to pip install flake8, etc. after sourcing ROS stuff.

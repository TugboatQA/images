This Makefile is intended to be used as an include inside of a Makefile for your
Tugboat project. To include it, place the following line at the top of your
Makefile:

-include /usr/share/tugboat/Makefile

Make sure to keep the hyphen at the beginning of the include if you want your
Makefile to work on non-Tugboat environments.

Alternately, you can call '$(MAKE) -C /usr/share/tugboat foo' from within a
target if you don't want to include this Makefile in its entirety.

After you've included it, you may call 'make _targets' to see the available
targets to use.

To learn more about Make syntax:
 - http://makefiletutorial.com/
 - http://www.gnu.org/software/make/manual/make.html
 - https://gist.github.com/isaacs/62a2d1825d04437c6f08

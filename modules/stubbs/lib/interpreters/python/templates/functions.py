#
# common functions for @MODULE@ commands
#


#
# error handling functions -
#
import sys

# Print the message and exit.
def rerun_die(message):
	"Prints the message to stderr and exits 1"
	print >> sys.stderr, "ERROR: ", message 
	sys.exit(1)



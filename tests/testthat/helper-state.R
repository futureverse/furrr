# Detects leaked workers in tests, which show up as:
#
# ```
# Warning message:
# In .Internal(gc(verbose, reset, full)) :
#   closing unused connection 4 (<-localhost:11913)
# ```
#
# If a leaked connection is detected, a warning is thrown by testthat for
# the problematic test.
#
# We keep this on constantly to ensure we aren't leaking connections. It has
# also been helpful for detecting future issues around leaked workers (#307).
set_state_inspector(function() {
  getAllConnections()
})

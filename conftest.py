'''
The potential and common use of conftest.py:
-------------------------------------------

Fixtures:                Define fixtures for static data used by tests.
                         This data can be accessed by all tests in the suite unless specified otherwise.
                         This could be data as well as helpers of modules which will be passed to all tests.

External plugin loading: conftest.py is used to import external plugins or modules.
                         By defining the following global variable, pytest will load the module and make it available for its test.
                         Plugins are generally files defined in your project or other modules which might be needed in your tests.
                         You can also load a set of predefined plugins as explained here:
                             pytest_plugins = "someapp.someplugin"

Hooks:                   You can specify hooks such as setup and teardown methods and much more to improve your tests.
                         For a set of available hooks, read here. Example:
                             def pytest_runtest_setup(item):
                                  """ called before ``pytest_runtest_call(item). """
                                  #do some stuff`

Test root path:          This is a bit of a hidden feature.
                         By defining conftest.py in your root path, you will have pytest recognizing your application modules without specifying PYTHONPATH.
                         In the background, py.test modifies your sys.path by including all submodules which are found from the root path.
'''
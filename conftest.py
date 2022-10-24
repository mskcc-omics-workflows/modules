from pytest import fixture


def pytest_addoption(parser):
    parser.addoption("--yml", action="store", default="")
    parser.addoption("--module", action='store', default="")

@fixture()
def yml(request):
    return request.config.getoption("--yml")

@fixture()
def module(request):
    return request.config.getoption("--module")

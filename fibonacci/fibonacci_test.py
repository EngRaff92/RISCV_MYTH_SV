from cocotb_test.simulator import run
from glob import glob
import pytest

@pytest.mark.parametrize("parameters", [{"DW" : "32", "DUMP_NAME" : "fibonacci_dump"}])
def test_fibonacci(parameters):
    run(
        verilog_sources     = ["./en_ff.sv","./fibonacci.sv",],
        toplevel            = "fibonacci",                # top level HDL
        module              = "fibonacci_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    )

@pytest.mark.parametrize("parameters", [{   "DW" : "32", "DUMP_NAME" : "fibonacci_piped_dump"}])
def test_fibonacci_piped(parameters):
    run(
        verilog_sources     = ["./pipe_ff.sv","./en_ff.sv","./fibonacci_piped.sv",],
        toplevel            = "fibonacci_piped",                # top level HDL
        module              = "fibonacci_piped_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    )   
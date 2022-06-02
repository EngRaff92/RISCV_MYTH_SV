from cocotb_test.simulator import run
from glob import glob
import pytest

@pytest.mark.parametrize("parameters", [{"DW": "32"},])
def test_pythagora_th(parameters):
    run(
        verilog_sources     = ["./clock_g.sv","./en_ff.sv","./pythagora_th.sv","./sqrt_int.sv",],
        toplevel            = "pythagora_th",                # top level HDL
        module              = "pythagora_th_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    )
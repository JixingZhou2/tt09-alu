# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")


    TEST_CASE_COUNT = 100

    # Store expected results for each test case
    expected_results = []
    actual_results = []

    for i in range(TEST_CASE_COUNT):
        # Randomize input values
        ui_in = random.randint(0, 255)
        uio_in = (random.randint(0, 255))&0xfe
        dut.ui_in.value = ui_in
        dut.uio_in.value = uio_in

        # Extract individual fields from ui_in and uio_in
        a = (ui_in >> 4) & 0xF
        b = ui_in & 0xF
        c = (uio_in >> 4) & 0x3
        opcode = (uio_in >> 2) & 0x3
        inmode = (uio_in) & 0x2

        # Compute expected result
        if opcode == 0b00:
            if inmode == 0b00:
                expected_result = a * (b + c)
            elif inmode == 0b10:
                expected_result = a * ((c << 4) | b)
            else:
                expected_result = 0
        elif opcode == 0b01:
            if inmode == 0b00:
                expected_result = a + b + c
            elif inmode == 0b10:
                expected_result = a + ((c << 4) | b)
            else:
                expected_result = 0
        elif opcode == 0b10:
            if inmode == 0b00:
                expected_result = (b + c - a) & 0x3FF
            elif inmode == 0b10:
                expected_result = (((c << 4) | b) - a) & 0x3FF
            else:
                expected_result = 0
        elif opcode == 0b11:
            if inmode == 0b00:
                expected_result = a ^ (b + c)
            elif inmode == 0b10:
                expected_result = a ^ ((c << 4) | b)
            else:
                expected_result = 0
        else:
            expected_result = 0

        # Limit expected_result to 10 bits
        expected_result &= 0x3FF
        # Append actual results
        dut_result = int((int(dut.uio_out.value) << 2 & 0x300)|(dut.uo_out.value)&0xff)

        # Store the expected result for later verification
        expected_results.append((i + 1, a, b, c, opcode, inmode, expected_result))
        if i > 3:
            actual_results.append(dut_result)
        await ClockCycles(dut.clk, 1)

    # Wait for the pipeline to process all inputs
    for i in range(4):
        dut_result = int((int(dut.uio_out.value) << 2 & 0x300)|(dut.uo_out.value)&0xff)
        actual_results.append(dut_result)
        await ClockCycles(dut.clk, 1)

    # Verify the results
    for i, (test_case, a, b, c, opcode, inmode, expected_result) in enumerate(expected_results):
        actual_result = actual_results[i]
        print(f"Test Case {test_case}: A = {a}, B = {b}, C = {c}, Opcode = {opcode}, Inmode = {inmode}, Expected Result = {expected_result}, Actual Result = {actual_result}")
        dut._log.info(f"Test Case {test_case}: A = {a}, B = {b}, C = {c}, Opcode = {opcode}, Inmode = {inmode}, Expected Result = {expected_result}, Actual Result = {actual_result}")
        print(f"Expected Result: {expected_result}")

        # Assert the output value
        assert actual_result == expected_result, f"Mismatch in Test Case {test_case}: Expected {expected_result}, got {dut_result}"

    dut._log.info("All test cases passed")
    print("All test cases passed")

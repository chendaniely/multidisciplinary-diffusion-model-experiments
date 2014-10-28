#! /usr/bin/env python

import configparser
import os
import numpy as np
import shutil

here = os.path.abspath(os.path.dirname(__file__))

sweep_batch_config = configparser.ConfigParser()
sweep_batch_config_file = os.path.join(here, 'batch_sweep.ini')
sweep_batch_config.read(sweep_batch_config_file)

print(sweep_batch_config_file)

print(sweep_batch_config.get('sweep', 'NumberOfWeightTrainExampleMutations'))


def parse_config_fr_to_by(config_string):
    config_string = config_string.strip()
    fr_to_by_list = config_string.split('\n')
    fr_to_by_str = tuple(e.split("=")[1].strip() for e in fr_to_by_list)
    fr_to_by_float = map(float, fr_to_by_str)
    return fr_to_by_float


def get_sweep_values(fr, to, by):
    values = np.arange(fr, to, by)
    # make the range inclusive on the right, since this is what
    # the usuer will most likely mean in the parameter file
    values = np.append(values, values[-1] + by)
    return values


ftb_str = sweep_batch_config.get('sweep', 'NumberOfWeightTrainExampleMutations')

f, t, b = parse_config_fr_to_by(ftb_str)
print(f, t, b)

sweep_values = np.arange(f, t, b)
print(str(sweep_values))

print(get_sweep_values(f, t, b))

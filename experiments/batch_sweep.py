#! /usr/bin/env python

import configparser
import os
import numpy as np
import shutil
import subprocess


def parse_config_fr_to_by(config_string):
    """Returns the value for the fr, to, and by, values in the config file.

    Args:
        config_string (string): a string of fr, to, by values
                                separated by \n character

    Returns:
        tuple: float of number to the right of the fr, to, and by values in the
               config file
    """
    config_string = config_string.strip()
    fr_to_by_list = config_string.split('\n')

    # for each fr, to, by value, take the value to the right of the equal sign
    fr_to_by_str = tuple(e.split("=")[1].strip() for e in fr_to_by_list)

    fr_to_by_float = map(float, fr_to_by_str)
    return fr_to_by_float


def get_sweep_values(fr, to, by):
    """Returns an ndarray values that will be used for the simulation run.

    Will include the 'to' value if the 'by' step will does not exceed the
    'to' value

    Args:
        fr (float): value of where the sweep will start
        to (float): value of where the sweep will end
        by (float): values between fr and to by specified step

    Returns:
        values (ndarray): of values for parameter sweep

    Examples:
        >>> print(get_sweep_values(0, 10, 2))
        array([0, 2, 4, 6, 8, 10])

        >>> print(get_sweep_values(1, 10, 2))
        array([1, 3, 5, 7, 9])
    """
    values = np.arange(fr, to, by)
    # make the range inclusive on the right, since this is what
    # the usuer will most likely mean in the parameter file
    end_value = values[-1] + by
    if end_value == to:
        values = np.append(values, values[-1] + by)
    return values


def copy_directory(src, dest):
    try:
        shutil.copytree(src, dest)
    # Directories are the same
    except shutil.Error as e:
        print('Directory not copied. Error: %s' % e)
    # Any error saying that the directory doesn't exist
    except OSError as e:
        print('Directory not copied. Error: %s' % e)


def ftb_string_to_values(ftb_string):
    f, t, b = parse_config_fr_to_by(ftb_string)
    # print(f, t, b)

    sweep_values = np.arange(f, t, b)
    # print(str(sweep_values))

    # print(get_sweep_values(f, t, b))
    sweep_values = get_sweep_values(f, t, b)
    return sweep_values


here = os.path.abspath(os.path.dirname(__file__))

sweep_batch_config = configparser.ConfigParser()
sweep_batch_config_dir = os.path.join(here, 'batch_sweep.ini')
sweep_batch_config.read(sweep_batch_config_dir)

# print(sweep_batch_config_dir)

# print(sweep_batch_config.get('Sweep', 'WeightTrainExampleMutationsProb'))


# TODO this is a ver inefficicent and unscalable way to get a list of sweep
# parameters, need to generalize this
mutations_ftb_str = sweep_batch_config.get('Sweep',
                                           'WeightTrainExampleMutationsProb')
criterion_ftb_str = sweep_batch_config.get('Sweep', 'Criterion')

mutations_sweep_values = ftb_string_to_values(mutations_ftb_str)
criterions_sweep_values = ftb_string_to_values(criterion_ftb_str)

base_directory = sweep_batch_config.get('General', 'BaseDirectory')
base_directory_name = os.path.join(here, base_directory)


def update_init_file(mi, ci, folder_name):
    sim_config = configparser.SafeConfigParser()
    sim_config_file_dir = os.path.join(folder_name, 'config.ini')
    sim_config.read(sim_config_file_dir)
    sim_config.set('LENSParameters', 'WeightTrainExampleMutationsProb',
                   str(int(mutations_sweep_values[mi])))
    sim_config.set('LENSParameters', 'Criterion',
                   str(int(criterions_sweep_values[ci])))
    with open(sim_config_file_dir, 'w') as update_config:
        sim_config.write(update_config)

list_of_sim_names = []
for mi, mutation in enumerate(mutations_sweep_values):
    for ci, criterion in enumerate(criterions_sweep_values):
        mutation_str_int = "{0:02f}".format(float(mutation))
        criterion_str_int = "{0:02d}".format(int(criterion))
        new_folder_name = '_'.join([base_directory_name,
                                    'd'+mutation_str_int,
                                    'c'+criterion_str_int])
        list_of_sim_names.append(new_folder_name)
        new_directory_name = os.path.join(here, base_directory+'_batch',
                                          new_folder_name)
        copy_directory(base_directory_name, new_directory_name)
        update_init_file(mi, ci, new_directory_name)


# for folder in enumerate(list_of_sim_names):
#     for i in range(len(mutations_sweep_values)):
#         update_init_file(idx, folder)


def run_simulation(folder_name):
        ex_file = os.path.join(folder_name, 'main.py')
        subprocess.call(['python', ex_file])


import multiprocessing as mp

num_cores = mp.cpu_count()
pool = mp.Pool(processes=num_cores)

# results = [pool.apply_async(cube, args=(x,)) for x in range(1,7)]
# output = [p.get() for p in results]
# print(output)

pool.map(run_simulation, list_of_sim_names)

# for folder in list_of_sim_names:
#     run_simulation(folder)

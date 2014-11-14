#! /usr/bin/env python
"""Create and dispatch separate simulations based on parameter sweep

This module will read in the accompanying configuration file
and create a folder with the base folder provided in the config file +
the current GMT time.
For example: of the base folder specified is '02-lens'
then a folder titled: 02-lens_batch_YYYY-MM-DD_HH-MM-SS
will be created.

In side this newly created folder, subfolders named by the
mutation, criterion, and run number will be created (d,c,r),
each will be a copy of the base folder (e.g., 02-lens).
These dcr represent a simulation, and will be run in parallel according
to the total number of cores availiable
"""

import configparser
import os
import numpy as np
import shutil
import subprocess
import multiprocessing as mp
from time import gmtime, strftime
import itertools


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
        values (ndarray): values for parameter sweep

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


def format_values(tuple_of_values):
    mutation, criterion, run_number = tuple_of_values

    mutation = float("{0:.2f}".format(mutation))
    criterion = int(criterion)
    run_number = int(run_number)

    assert isinstance(mutation, float)
    assert isinstance(criterion, int)
    assert isinstance(run_number, int)

    return mutation, criterion, run_number


def create_folder(base_directory, mutation_str, criterion_str,
                  run_number_str):
    # print('m: {}, c: {}, r: {}'.format(mutation_str, criterion_str,
    #                                    run_number_str))
    new_sim_folder_name = '_'.join(['d'+mutation_str,
                                    'c'+criterion_str,
                                    'r'+run_number_str])
    # print(new_sim_folder_name)

    batch_folder_name = '_'.join([base_directory, 'batch', current_gmt_time])
    # print('batch folder name: ', batch_folder_name)

    dir_to_copy_from = os.path.join(here, base_directory)
    # print('from: ', dir_to_copy_from)

    batch_folder_full_path = os.path.join(here, batch_folder_name)

    if not os.path.exists(batch_folder_full_path):
        # print('created: ', batch_folder_full_path)
        os.makedirs(batch_folder_full_path)

    dir_to_copy_to = os.path.join(batch_folder_full_path,
                                  new_sim_folder_name)
    # print('to : ', dir_to_copy_to)

    copy_directory(dir_to_copy_from, dir_to_copy_to)
    return dir_to_copy_to


def update_init_file(mutation, criterion, run, folder_name):
    """Updates the config file for a particular set of parameters for sweep

    Args:
        mutation (float): mutation value parameter for sweep
        ci (int): criterion value parameter for sweep
        run_number (int): run number for a set of value parameters for sweep
    """
    assert isinstance(mutation, float)
    assert isinstance(criterion, int)
    assert isinstance(run_number, int)

    sim_config = configparser.SafeConfigParser()
    sim_config_file_dir = os.path.join(folder_name, 'config.ini')
    sim_config.read(sim_config_file_dir)
    sim_config.set('LENSParameters', 'WeightTrainExampleMutationsProb',
                   str(mutation))
    sim_config.set('LENSParameters', 'Criterion', str(criterion))
    sim_config.set('General', 'RunNumber', str(run_number))
    with open(sim_config_file_dir, 'w') as update_config:
        sim_config.write(update_config)
        # print('config file updated: ', sim_config_file_dir)


def num_cores():
    cores = mp.cpu_count()
    print("Number of cores on this computer: ", cores)
    if cores <= 4:
        return cores
    else:
        return int(cores * (2/3.0))


def run_simulation(folder_name):
        ex_file = os.path.join(folder_name, 'main.py')
        subprocess.call(['python', ex_file])


here = os.path.abspath(os.path.dirname(__file__))

# read in the parameter file
sweep_batch_config = configparser.ConfigParser()
sweep_batch_config_dir = os.path.join(here, 'batch_sweep.ini')
sweep_batch_config.read(sweep_batch_config_dir)

# TODO can reading in sweep values be generalized?
num_sims_per_sweep_set = sweep_batch_config.getint(
    'Batch', 'NumberOfSimulationsPerSweepSet')
mutations_ftb_str = sweep_batch_config.get('Sweep',
                                           'WeightTrainExampleMutationsProb')
criterion_ftb_str = sweep_batch_config.get('Sweep', 'Criterion')

mutations_sweep_values = ftb_string_to_values(mutations_ftb_str)
criterions_sweep_values = ftb_string_to_values(criterion_ftb_str)

current_gmt_time = strftime("%Y-%m-%d_%H:%M:%S", gmtime())
base_directory = sweep_batch_config.get('General', 'BaseDirectory')
base_directory_name = os.path.join(here, base_directory)

list_of_parameters = [mutations_sweep_values,
                      criterions_sweep_values,
                      range(num_sims_per_sweep_set)]
combination_of_parameters = itertools.product(*list_of_parameters)
for combo in combination_of_parameters:
    mutation, criterion, run_number = format_values(combo)

    # print('m: {}, c: {}, r: {}'.format(mutation, criterion, run_number))
    mutation_str = "{0:03d}".format(int(mutation * 100))
    criterion_str = "{0:02d}".format(int(criterion))
    run_number_str = "{0:02d}".format(int(run_number))
    folder_created = create_folder(base_directory, mutation_str,
                                   criterion_str, run_number_str)

list_of_sim_names = []
# for mi, mutation in enumerate(mutations_sweep_values):
#     for ci, criterion in enumerate(criterions_sweep_values):
#         mutation_str_int = "{0:02f}".format(float(mutation))
#         criterion_str_int = "{0:02d}".format(int(criterion))
#         new_folder_name = '_'.join([base_directory_name,
#                                     'd'+mutation_str_int,
#                                     'c'+criterion_str_int])
#         list_of_sim_names.append(new_folder_name)
#         new_directory_name = os.path.join(here, base_directory+'_batch',
#                                           new_folder_name)
#         copy_directory(base_directory_name, new_directory_name)
#         update_init_file(mi, ci, new_directory_name)


num_cores = num_cores()
print("Number of cores for batch sweep simulation: ", num_cores)
pool = mp.Pool(processes=num_cores)

# pool.map(run_simulation, list_of_sim_names)

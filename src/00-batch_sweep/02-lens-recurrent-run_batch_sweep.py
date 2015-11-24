#! /usr/bin/env python

import os
import configparser
import datetime
import itertools
import multiprocessing as mp
import numpy as np
import collections
from time import sleep

import mann.batch_sweep

# print(mann.batch_sweep.num_cores())
HERE = os.path.abspath(os.path.dirname(__file__))


def read_sweep_type_values(configparser_object, sweep_type, sweep_values):
    return((configparser_object.get('Sweep', sweep_type),
            configparser_object.get('Sweep', sweep_values)))


def named_product(**items):
    Product = collections.namedtuple('Product', items.keys())
    return itertools.starmap(Product, itertools.product(*items.values()))


def create_simulation_folders(base_directory, here, current_time, **kwargs):
    assert len(kwargs) == 7
    new_sim_folder_name = 'a{}_bm{}_bs{}_wm{}_ws{}_c{}_r{:03d}'.format(
        kwargs['agents'],
        kwargs['between_mean'],
        kwargs['between_sd'],
        kwargs['within_mean'],
        kwargs['within_sd'],
        kwargs['clamp_strength'],
        kwargs['run'])
    print("new sim folder name: ", new_sim_folder_name)

    new_batch_folder_name = '_'.join([base_directory,
                                      'batch',
                                      current_time])
    print("new batch folder name: ", new_batch_folder_name)

    dir_to_copy_from = os.path.join(here, '..', base_directory)
    print('from: ', dir_to_copy_from)

    batch_folder_path = os.path.join(here, '..', '..',
                                     'results', 'simulations',
                                     new_batch_folder_name)

    dir_to_copy_to = os.path.join(batch_folder_path,
                                  new_sim_folder_name)
    print('to : ', dir_to_copy_to)

    if not os.path.exists(batch_folder_path):
        os.makedirs(batch_folder_path)
        print('created: ', batch_folder_path)

    mann.batch_sweep.copy_directory(dir_to_copy_from, dir_to_copy_to)

    new_config_file_path = os.path.join(dir_to_copy_to, 'config.ini')
    print(new_config_file_path)
    print("Does the new config exist?: ", os.path.isfile(new_config_file_path))
    update_config_file(new_config_file_path, **kwargs)

    return dir_to_copy_to


def update_config_file(configfile_path, **kwargs):
    print("updating :", configfile_path)
    recodes = {'agents': 'NumberOfAgents',
               'run': 'BatchRunNumber',
               'between_mean': 'BetweenMean', 'between_sd': 'BetweenSd',
               'within_mean': 'WithinMean', 'within_sd': 'WithinSd',
               'clamp_strength': 'ClampStrength'}
    single_sim_cfg = configparser.ConfigParser()
    single_sim_cfg.read(configfile_path)
    for key, value in kwargs.items():
        if key in ['agents']:
            # NetworkParameters section
            single_sim_cfg.set('NetworkParameters', recodes[key], str(value))
        elif key in ['run']:
            # ModelParameters section
            single_sim_cfg.set('ModelParameters', recodes[key], str(value))
        elif key in ['between_mean', 'between_sd',
                     'within_mean', 'within_sd',
                     'clamp_strength']:
            # LENSParameters section
            single_sim_cfg.set('LENSParameters', recodes[key], str(value))
    with open(configfile_path, 'w') as new_cfg_file:
        single_sim_cfg.write(new_cfg_file)
    return(1)


def main():
    #
    # READ IN PARAMETER FILE VALUES
    #
    configfile_path = os.path.join(
        HERE, 'example_config_lens_recurrent_batch_sweep.ini')
    sweep_batch_config = configparser.ConfigParser()
    sweep_batch_config.read(configfile_path)

    num_sims_per_sweep_set = sweep_batch_config.getint(
        'Batch', 'NumberOfSimulationsPerSweepSet')

    # Read in number of agents in the simulation
    agents_str = sweep_batch_config.get('Sweep', 'NumberOfAgents')
    agents_sweep_type_str = sweep_batch_config.get(
        'Sweep', 'NumberOfAgentsSweepType')

    # Read in clap values
    clamp_type_str = sweep_batch_config.get('Sweep', 'ClampType')
    clamp_str = sweep_batch_config.get('Sweep', 'ClampValues')

    # Read in Between Bank mean
    between_bank_mean_type_str, between_bank_mean_str = read_sweep_type_values(
        sweep_batch_config, 'BetweenBankMeanType', 'BetweenBankMeanValues')

    # Read in Between Bank SD
    between_bank_sd_type_str, between_bank_sd_str = read_sweep_type_values(
        sweep_batch_config, 'BetweenBankSdType', 'BetweenBankSdValues')

    # Read in Within Bank mean
    within_bank_mean_type_str, within_bank_mean_str = read_sweep_type_values(
        sweep_batch_config, 'WithinBankMeanType', 'WithinBankMeanValues')

    # Read in Within Bank SD
    within_bank_sd_type_str, within_bank_sd_str = read_sweep_type_values(
        sweep_batch_config, 'WithinBankSdType', 'WithinBankSdValues')

    print("clamp_type_str: ", clamp_type_str, clamp_str)
    print("BetweenBankMean: ", between_bank_mean_type_str,
          between_bank_mean_str)
    print("BetweenBankSd: ", between_bank_sd_type_str, between_bank_sd_str)
    print("WithinBankMdan: ", within_bank_mean_type_str, within_bank_mean_str)
    print("WithinBankSd:", within_bank_sd_type_str, within_bank_sd_str)

    #
    # CONVERT PARAMETER STRINGS TO PYTHON ARRAY VALUES (GET SWEEP VALUES)
    #
    # Convert number of agents in sim to a list of ints
    agents_sweep_values = mann.batch_sweep.get_sweep_values(
        agents_str, agents_sweep_type_str)
    clamp_sweep_values = mann.batch_sweep.get_sweep_values(
        clamp_str, clamp_type_str)
    between_bank_mean_values = mann.batch_sweep.get_sweep_values(
        between_bank_mean_str, between_bank_mean_type_str)
    between_bank_sd_values = mann.batch_sweep.get_sweep_values(
        between_bank_sd_str, between_bank_sd_type_str)
    within_bank_mean_values = mann.batch_sweep.get_sweep_values(
        within_bank_mean_str, within_bank_mean_type_str)
    within_bank_sd_values = mann.batch_sweep.get_sweep_values(
        within_bank_sd_str, within_bank_sd_type_str)

    print("Agents sweep values: ", agents_sweep_values)
    print("clamp sweep values: ", clamp_sweep_values, type(clamp_sweep_values),
          len(clamp_sweep_values))
    print("between bank mean values: ", between_bank_mean_values,
          type(between_bank_mean_values), len(between_bank_mean_values))
    print("between bank sd values: ", between_bank_sd_values,
          type(between_bank_sd_values), len(between_bank_sd_values))
    print("within bank mean values: ", within_bank_mean_values,
          type(within_bank_mean_values), len(within_bank_mean_values))
    print("within bank sd values: ", within_bank_sd_values,
          type(within_bank_sd_values), len(within_bank_sd_values))

    num_sims_per = np.array(range(num_sims_per_sweep_set))
    print("number of sims per sweep set: ", num_sims_per)

    #
    # Cartesian product of parms to create sim folder with timestamp
    #
    now = datetime.datetime.now()
    current_time = now.strftime("%Y-%m-%d_%H-%M-%S")
    print("current time: ", current_time)

    base_directory = sweep_batch_config.get('General', 'BaseDirectory')
    base_directory_path = os.path.join(HERE, '..', base_directory)

    tuple_of_parameters = tuple((agents_sweep_values,
                                 clamp_sweep_values,
                                 between_bank_mean_values,
                                 between_bank_sd_values,
                                 within_bank_mean_values,
                                 within_bank_sd_values,
                                 range(num_sims_per_sweep_set)))

    print("Parameters: ", str(tuple_of_parameters))

    # model_parameters = collections.namedtuple('model_parameters')

    list_of_sim_names = []
    # iterate though each set of the cartesian product
    for model_number, model_parameter_set in enumerate(named_product(
            agents_sweep_values=agents_sweep_values,
            clamp_sweep_values=clamp_sweep_values,
            between_bank_mean_values=between_bank_mean_values,
            between_bank_sd_values=between_bank_sd_values,
            within_bank_mean_values=within_bank_sd_values,
            within_bank_sd_values=within_bank_sd_values,
            num_sims_per=num_sims_per)):
        print("*" * 80)
        # print(model_number)
        # print(model_parameter_set)
        # print("param:", model_parameter_set.agents_sweep_values)
        # print("param:", model_parameter_set.clamp_sweep_values)
        model_parameters = mann.batch_sweep.format_values(base_directory,
                                                          model_parameter_set)
        print("Model Parameters: ", model_parameters)

        folder_created = create_simulation_folders(
            base_directory, HERE, current_time,
            agents=model_parameters.agents,
            between_mean=model_parameters.between_mean,
            between_sd=model_parameters.between_sd,
            within_mean=model_parameters.within_mean,
            within_sd=model_parameters.within_sd,
            clamp_strength=model_parameters.clamp_strength,
            run=model_parameters.run)

        list_of_sim_names.append(folder_created)

        if model_number == 0:
            break
            # continue
    # print(list_of_sim_names)
    print("Number of simulations: ", len(list_of_sim_names))
    # return(1)
    # combination_of_parameters = itertools.product(*tuple_of_parameters)
    # # print("Cartesian product of parameters: ",
    # #       str(combination_of_parameters))

    # # print("Total number of simulations: ",
    # #       len(combination_of_parameters))
    # # print(str(combination_of_parameters))
    # # return(1)

    # # fmt = '{0:15} ${1:>6}'

    # for combo in combination_of_parameters:
    #     assert(len(combo) == 7)
    #     print(mann.batch_sweep.format_values(base_directory, combo))
    #     print("*" * 80)
    #     agents, run = mann.batch_sweep.format_values(base_directory, combo)

    #     agents_str = "{0:06d}".format(int(agents))
    #     run_str = "{0:02d}".format(int(run))

    #     folder_created = mann.batch_sweep.create_folder(
    #         base_directory,
    #         HERE,
    #         current_time=current_time,
    #         agents_str=agents_str,
    #         run_str=run_str)

    #     list_of_sim_names.append(folder_created)

    #     # mann.batch_sweep.update_init_file(folder_created,
    #     #                                   agents=agents,
    #     #                                   run=run)
    num_cores = mann.batch_sweep.num_cores()
    use_cores = sweep_batch_config.getint('General', 'NumCoresToUse')
    assert use_cores <= num_cores
    print("Number of cores for batch sweep simulation: ", use_cores)

    pool = mp.Pool(processes=use_cores)
    sleep(5)
    return(1)
    pool.map(mann.batch_sweep.run_simulation, list_of_sim_names)


if __name__ == "__main__":
    main()

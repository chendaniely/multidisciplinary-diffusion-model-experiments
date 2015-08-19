#! /usr/bin/env python

import os
import configparser
import datetime
import itertools
import multiprocessing as mp

import mann.batch_sweep

print(mann.batch_sweep.num_cores())
HERE = os.path.abspath(os.path.dirname(__file__))


def create_simulation_folders():
    pass


def main(configfile_path):
    #
    # READ IN PARAMETER FILE VALUES
    #
    sweep_batch_config = configparser.ConfigParser()
    sweep_batch_config.read(configfile_path)

    num_sims_per_sweep_set = sweep_batch_config.getint(
        'Batch', 'NumberOfSimulationsPerSweepSet')

    # Read in number of agents in the simulation
    agents_str = sweep_batch_config.get('Sweep', 'NumberOfAgents')
    agents_sweep_type_str = sweep_batch_config.get(
        'Sweep', 'NumberOfAgentsSweepType')

    #
    # CONVERT PARAMETER STRINGS TO PYTHON ARRAY VALUES (GET SWEEP VALUES)
    #
    # Convert number of agents in sim to a list of ints
    agents_sweep_values = mann.batch_sweep.get_sweep_values(
        agents_str, agents_sweep_type_str)
    print("Agents sweep values: ", agents_sweep_values)

    #
    # Cartesian product of paras to create sim folder with timestamp
    #
    now = datetime.datetime.now()
    current_time = now.strftime("%Y-%m-%d_%H-%M-%S")
    print("current time: ", current_time)

    base_directory = sweep_batch_config.get('General', 'BaseDirectory')
    base_directory_path = os.path.join(HERE, '..', base_directory)

    tuple_of_parameters = tuple((agents_sweep_values,
                                 range(num_sims_per_sweep_set)))

    print("Parameters: ", str(tuple_of_parameters))

    combination_of_parameters = tuple(itertools.product(*tuple_of_parameters))

    print("Cartesian product of parameters: ",
          str(combination_of_parameters))

    print("Total number of simulations: ",
          len(combination_of_parameters))
    print(str(combination_of_parameters))

    list_of_sim_names = []
    # fmt = '{0:15} ${1:>6}'

    for combo in combination_of_parameters:
        assert(len(combo) == 2)
        print(mann.batch_sweep.format_values(base_directory, combo))
        print("*" * 80)
        agents, run = mann.batch_sweep.format_values(base_directory, combo)

        agents_str = "{0:06d}".format(int(agents))
        run_str = "{0:02d}".format(int(run))

        folder_created = mann.batch_sweep.create_folder(
            base_directory,
            HERE,
            current_time=current_time,
            agents_str=agents_str,
            run_str=run_str)

        list_of_sim_names.append(folder_created)

        # mann.batch_sweep.update_init_file(folder_created,
        #                                   agents=agents,
        #                                   run=run)

    num_cores = mann.batch_sweep.num_cores()
    print("Number of cores for batch sweep simulation: ", num_cores)
    pool = mp.Pool(processes=num_cores)

    pool.map(mann.batch_sweep.run_simulation, list_of_sim_names)


if __name__ == "__main__":
    sweep_batch_config_path = os.path.join(
        HERE, 'example_config_lens_recurrent_batch_sweep.ini')
    main(sweep_batch_config_path)

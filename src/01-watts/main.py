#! /usr/bin/env python

import os
import logging
import configparser

import mann.network
import mann.network_agent
import mann.agent_binary

# get the current location of where this script is
HERE = os.path.abspath(os.path.dirname(__file__))

# create a logging file, create file and directory if encouters a
# FileNotFoundError exception
while True:
    try:
        logging_file_dir = os.path.join(HERE, 'output')
        logging_file_path = os.path.join(logging_file_dir, '01-watts.log')
        logging_format = '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
        logging.basicConfig(level=logging.DEBUG,
                            format=logging_format,
                            datefmt='%m-%d %H:%M',
                            filename=logging_file_path,
                            filemode='w')

        # define a Handler which writes INFO messages
        # or higher to the sys.stderr
        console = logging.StreamHandler()
        console.setLevel(logging.INFO)

        # set a format which is simpler for console use
        formatter = logging.Formatter(
            '%(name)-12s: %(levelname)-8s %(message)s')

        # tell the handler to use this format
        console.setFormatter(formatter)

        # add the handler to the root logger
        logging.getLogger('').addHandler(console)

        # Now, we can log to the root logger, or any other logger.
        # First the root..
        logging.info('Logger created in main.py')

        # Now, define a couple of other loggers which might
        # represent areas in your application:
        logger_mdme = logging.getLogger('mdme')
        logger_mann = logging.getLogger('mann')

        logger_mdme.info("Logs created")
        break
    except FileNotFoundError:
        # Because the output folder does not exist, let's create it
        logging.info('Logger failed in main.py, '
                     'going to create output folder and retry')
        if not os.path.exists(logging_file_dir):
            os.makedirs(logging_file_dir)
        continue

# setting up the configparser
config = configparser.ConfigParser()
config_path = os.path.join(HERE, 'config.ini')
config.read(config_path)
with open(config_path) as f:
    for idx, line in enumerate(f):
        logger_mdme.info("Config line: {:03d}: {}".format(idx, line.strip()))


def setup(agent_type, model_output_path):
    logger_mdme.info('In main.setup()')
    # creating n number of agents
    n = config.getint('NetworkParameters', 'NumberOfAgents')
    logger_mdme.debug('Number of agents to create: %s', str(n))

    # probablity for edge creation [0, 1]
    p = config.getfloat('NetworkParameters', 'ProbEdgeCreation')
    logger_mdme.debug('Probablity for edge creation: %s', str(p))

    # Create Erdos-Renyi graph
    my_network = mann.network.DirectedFastGNPRandomGraph(n, p)
    logger_mdme.info('Network graph created')

    logger_mdme.debug('Network edge list to copy (first 20 max shown): %s',
                      str(my_network.G.edges()[:20]))

    generated_graph_path = os.path.join(HERE, 'output', 'nx-generated.png')
    my_network.show_graph(generated_graph_path)
    logger_mdme.info('Generated graph saved as %s', generated_graph_path)

    network_of_agents = mann.network_agent.NetworkAgent()
    network_of_agents.create_multidigraph_of_agents_from_edge_list(
        number_of_agents=n,
        edge_list=my_network.G.edges_iter(),
        fig_path=os.path.join(HERE, 'output', 'mann-generated.png'),
        agent_type=[agent_type, 0.18])

    edgelist_path = os.path.join(HERE, 'output', 'mann-generated.csv')
    network_of_agents.export_edge_list(edgelist_path)

    # write initial state of agents as time -2
    network_of_agents.\
        write_network_agent_step_info(-2, model_output_path, 'w', agent_type)

    logger_mdme.info('Assigning individual predecessors')

    network_of_agents.set_predecessors_for_each_node()

    logger_mdme.info('Finished assigning individual predecessors')

    return(network_of_agents)


def agents_to_seed(num_seed):
    pass


def seed(network_of_agents, agent_type, model_output_path):
    logger_mdme.info('In main.seed()')
    total_num_agents = config.getint('NetworkParameters', 'NumberOfAgents')
    try:
        num_seed = config.get('ModelParameters', 'NumberOfAgentsToSeedOnInit')
        num_seed = int(num_seed)
        assert num_seed <= total_num_agents, \
            'Attempted to seed too many agents. {} / {}'.\
            format(num_seed, total_num_agents)
    except ValueError:
        if num_seed == 'all':
            num_seed = total_num_agents
        else:
            raise ValueError

    agents_to_seed = network_of_agents.sample_network(num_seed)
    logger_mdme.info('Agents to seed: {}'.format(agents_to_seed))

    for agent_to_seed in agents_to_seed:
        logger_mdme.info('Seeding agent {}'.format(agent_to_seed.agent_id))
        logger_mdme.info('Seeding agent {} Pre-Seed {}'.
                         format(agent_to_seed.agent_id,
                                agent_to_seed.state))

        agent_to_seed.state = 1

        logger_mdme.info('Seeding agent {} Post-Seed {}'.
                         format(agent_to_seed.agent_id,
                                agent_to_seed.state))
    logger_mdme.info('Finished Seeding')

    # write seeded agents as time -1
    network_of_agents.\
        write_network_agent_step_info(-1, model_output_path, 'a', agent_type)
    return(network_of_agents)


def step(time_tick, network_of_agents, update_type, total_num_agents,
         model_output_path, agent_type, update_algorithm):
    logger_mdme.info('START STEP # {}'.format(time_tick))

    try:
        num_agent_update = config.get(
            'ModelParameters', 'NumberOfAgentsToUpdatePerTimeTick')
        num_agent_update = int(num_agent_update)
        assert num_agent_update <= total_num_agents, 'updating too many agents'
    except ValueError:
        if num_agent_update == 'all':
            num_agent_update = total_num_agents
        else:
            raise ValueError("Unknown value passed for num agents to Update")

    logger_mdme.info('Update type: {}'.format(update_type))

    if update_type == 'simultaneous':
        network_of_agents.update_simultaneous(num_agent_update,
                                              update_algorithm)

    elif update_type == 'sequential':
        network_of_agents.update_sequential(num_agent_update,
                                            update_algorithm)
    else:
        raise ValueError('Unknown simulation update type')
    network_of_agents.\
        write_network_agent_step_info(time_tick, model_output_path, 'a',
                                      agent_type)
    logger_mdme.info('END STEP # {}'.format(time_tick))


def main():
    logger_mdme.info('In main.main()')
    logger_mdme.info('Starting Mulit Agent Neural Network (MANN) '
                     'Watts Diffusion Model')

    model_output_path = os.path.join(
        HERE, 'output', config.get('General', 'ModelOutput'))
    agent_type = config.get('NetworkParameters', 'AgentType')
    total_num_agents = config.getint('NetworkParameters', 'NumberOfAgents')

    # setup
    network_of_agents = setup(agent_type, model_output_path)

    # seed
    network_of_agents = seed(network_of_agents, agent_type, model_output_path)

    # step
    logger_mdme.info('Beginning Steps')

    update_type = config.get('ModelParameters', 'UpdateType')
    logger_mdme.info('Update type: {}'.format(update_type))

    update_algorithm = config.get('ModelParameters', 'UpdateAlgorithm')
    logger_mdme.info('Update algorithm: {}'.format(update_algorithm))

    for i in range(config.getint('ModelParameters', 'NumberOfTimeTicks')):
        step(i, network_of_agents, update_type, total_num_agents,
             model_output_path, agent_type=agent_type,
             update_algorithm=update_algorithm)


if __name__ == "__main__":
    main()

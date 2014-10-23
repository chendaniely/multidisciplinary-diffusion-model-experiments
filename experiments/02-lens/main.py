#! /usr/bin/env python

import os
import logging
import configparser

import mann.network as network
import mann.network_agent as network_agent


# set up logging to file - see previous section for more details
logging_format = '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
logging.basicConfig(level=logging.DEBUG,
                    format=logging_format,
                    datefmt='%m-%d %H:%M',
                    filename='./output/myapp.log',
                    filemode='w')

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)

# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')

# tell the handler to use this format
console.setFormatter(formatter)

# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger. First the root..
logging.info('Logger created in main()')

# Now, define a couple of other loggers which might represent areas in your
# application:

logger1 = logging.getLogger('myapp.area1')
logger2 = logging.getLogger('myapp.area2')

# setting up the configparser
config = configparser.ConfigParser()
config.read('config.ini')


def random_select_and_update(network_of_agents):
    n = len(network_of_agents.G)

    # randomly select nodes from network_of_agents
    # select num_update number of the nodes for update
    num_update = config.getint('ModelParameters',
                               'NumberOfAgentsToUpdatePerTimeTick')
    agents_for_update = network_of_agents.sample_network(num_update)
    print('agents for update: ', agents_for_update)
    print('key of agent for update')
    print(network_of_agents.G.nodes()[agents_for_update[0].get_key()])

    # update agents who were selected
    for selected_agent in agents_for_update:
        print("updating: ",
              network_of_agents.G.nodes()[selected_agent.get_key()])
        # print('pre-update state', selected_agent.get_state())

        here = os.path.abspath(os.path.dirname(__file__))
        # lens_in_file_dir = here + '/' + './MainM1PlautFix2.in'
        # lens_in_file_dir = here + '/' + './UpdateFromInfl.in'
        lens_in_file_dir = here + '/' + config.get('LENSParameters',
                                                   'UpdateFromInflInFile')

        # agent_ex_file_dir = here + '/' + './AgentState.ex'
        agent_ex_file_dir = here + '/' + config.get('LENSParameters',
                                                    'AgentExFile')

        # infl_ex_file_dir = here + '/' + './Infl.ex'
        infl_ex_file_dir = here + '/' + config.get('LENSParameters',
                                                   'InflExFile')

        # agent_state_out_file_dir = here + '/' + './AgentState.out'
        agent_state_out_file_dir = here + '/' + config.get('LENSParameters',
                                                           'NewAgentStateFile')

        selected_agent.update_agent_state('default',
                                          lens_in_file=lens_in_file_dir,
                                          agent_ex_file=agent_ex_file_dir,
                                          infl_ex_file=infl_ex_file_dir,
                                          agent_state_out_file=agent_state_out_file_dir)
        # print('post-update state', selected_agent.get_state())


def step(time_tick, network_of_agents):
    logger1.debug('STEP TIME TICK: %s', str(time_tick))

    logger1.debug('Begin random select and update network of agents')
    random_select_and_update(network_of_agents)

    here = os.path.abspath(os.path.dirname(__file__))
    network_agent_step_time_dir = here + '/output/network_of_agents.pout'

    network_of_agents.write_network_agent_step_info(
        time_tick, network_agent_step_time_dir, 'a')
    logger1.debug('Time ticks %s values appended to %s',
                  str(time_tick),
                  network_agent_step_time_dir)


def main():
    logger1.info('In main.main()')
    logger1.info('Starting Mulit Agent Neural Network (MANN)')

    # creating n number of agents
    n = config.getint('NetworkParameters', 'NumberOfAgents')
    logger1.debug('Number of agents to create: %s', str(n))

    # probablity for edge creation [0, 1]
    p = config.getfloat('NetworkParameters', 'ProbEdgeCreation')
    logger1.debug('Probablity for edge creation: %s', str(p))

    # Create Erdos-Renyi graph
    my_network = network.DirectedFastGNPRandomGraph(n, p)

    # print("network edge list to copy\n", my_network.G.edges())  # edge list
    logger1.info('Network edge list to copy: %s', str(my_network.G.edges()))

    # print(my_network.G.edges_iter())

    generated_graph_dir = './output/mann-generated.png'
    my_network.show_graph(generated_graph_dir)
    logger1.info('Generated graph saved in %s', './output/mann-generated.png')

    here = os.path.abspath(os.path.dirname(__file__))
    # weight_in = here + '/WgtMakeM1.in'
    weight_in = here + config.get('LENSParameters', 'WeightInFile')
    # weight_dir = here + '/weights'
    weight_dir = here + config.get('LENSParameters', 'WeightsDirectory')

    network_of_agents = network_agent.NetworkAgent()
    network_of_agents.create_multidigraph_of_agents_from_edge_list(
        n, my_network.G.edges_iter(),
        agent_type=(config.get('NetworkParameters', 'AgentType'),
                    # TODO this interface should pass a kwarg so it is more
                    # generalizable
                    config.getint('LENSParameters',
                                  'TotalNumberOfProcessingUnits')),
        weight_in_file=weight_in,
        weight_dir=weight_dir,
        base_example=config.get('LENSParameters', 'WeightBaseExample'),
        num_train_examples=config.getint('LENSParameters',
                                         'NumberOfWeightTrainExamples'),
        num_train_mutations=config.getint('LENSParameters',
                                          'NumberOfWeightTrainExampleMutations')
    )

    network_of_agents.write_network_agent_step_info(
        -3, config.get('General', 'ModelOutput'), 'w')

    # make agents aware of predecessors
    # predecessors are agents who influence the current agent
    network_of_agents.set_predecessors_for_each_node()

    # randomly select nodes from network_of_agents to seed
    num_seed = config.getint('ModelParameters', 'NumberOfAgentsToSeedOnInit')
    agents_to_seed = network_of_agents.sample_network(num_seed)
    # print("agents to seed: ", agents_to_seed)
    logger1.info('Agents seeded: %s', str(agents_to_seed))

    lens_in_file_dir = here + '/' + config.get('LENSParameters',
                                               'UpdateFromInflInFile')

    agent_self_ex_file = here + '/' + config.get('LENSParameters',
                                                 'InflExFile')

    agent_self_out_file = here + '/' + config.get('LENSParameters',
                                                  'NewAgentStateFile')

    # seed agents who were select
    for selected_agent in agents_to_seed:
        # print("seeding: ",
        #       network_of_agents.G.nodes()[selected_agent.get_key()])
        logger1.info('Seeding agent  %s', str(selected_agent.get_key()))

        # print('pre-seed binary_state', selected_agent.binary_state)
        logger1.debug('Agent %s, pre-seed state: %s',
                      str(selected_agent.get_key()),
                      str(selected_agent.get_state()))

        # TODO REALLY HACKY CODE
        selected_agent.seed_agent_no_update(config.get('LENSParameters',
                                                       'weightBaseExample'))
        network_of_agents.write_network_agent_step_info(
            -2, config.get('General', 'ModelOutput'), 'a')

        selected_agent.seed_agent(config.get('LENSParameters',
                                             'WeightBaseExample'),
                                  lens_in_file_dir,
                                  agent_self_ex_file,
                                  agent_self_out_file)

        logger1.debug('Agent %s seeded', str(selected_agent.get_key()))

        # print('post-seed_agent_binary_state', selected_agent.binary_state)
        logger1.debug('Agent %s, post-seed state: %s',
                      str(selected_agent.get_key()),
                      str(selected_agent.get_state()))

    network_of_agents.write_network_agent_step_info(
        -1, config.get('General', 'ModelOutput'), 'a')

    logger1.info('Begin steps')
    for i in range(config.getint('ModelParameters', 'NumberOfTimeTicks')):
        print("STEP # ", i)
        step(i, network_of_agents)

if __name__ == "__main__":
    main()

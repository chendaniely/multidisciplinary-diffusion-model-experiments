#! /usr/bin/env python

import os
import logging
import configparser

import mann.network as network
import mann.network_agent as network_agent
import mann.agent as agent

here = os.path.abspath(os.path.dirname(__file__))

# set up logging to file - see previous section for more details
logging_format = '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
logging.basicConfig(level=logging.DEBUG,
                    format=logging_format,
                    datefmt='%m-%d %H:%M',
                    filename=os.path.join(here, 'output', 'myapp.log'),
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

logger1 = logging.getLogger(os.path.join(here, 'myapp.area1'))
logger2 = logging.getLogger(os.path.join(here, 'myapp.area2'))

# setting up the configparser
config = configparser.ConfigParser()
config.read(os.path.join(here, 'config.ini'))


def random_select_and_update(network_of_agents):
    # not needed bc num update per step is in config
    # n = len(network_of_agents.G)

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

        # here = os.path.abspath(os.path.dirname(__file__))
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
                                          agent_state_out_file=\
                                          agent_state_out_file_dir)
        # print('post-update state', selected_agent.get_state())


def update_simultaneous(network_of_agents, num_agents_update):
    """Simultaneously updates agents

    :param network_of_agents: NetworkX graph of agents
    :type network_of_agents: NetworkX graph

    :parm num_agents_update: Number of agents that will be picked for update
    :type num_agents_update: int
    """
    agents_for_update = network_of_agents.sample_network(num_agents_update)
    print('agents for update: ', agents_for_update)
    print('key of agent for update')
    print(network_of_agents.G.nodes()[agents_for_update[0].get_key()])

    lens_in_file_dir = os.path.join(here, config.get('LENSParameters',
                                                     'UpdateFromInflInFile'))

    agent_ex_file_dir = os.path.join(here, config.get('LENSParameters',
                                                      'AgentExFile'))

    infl_ex_file_dir = os.path.join(here, config.get('LENSParameters',
                                                     'InflExFile'))

    agent_state_out_file_dir = os.path.join(here,
                                            config.get('LENSParameters',
                                                       'NewAgentStateFile'))

    for selected_agent in agents_for_update:
        print("updating: ",
              network_of_agents.G.nodes()[selected_agent.get_key()])
        assert selected_agent.temp_new_state is None
        selected_agent.temp_new_state = selected_agent.calculate_new_state(
            'default',
            lens_in_file=lens_in_file_dir,
            agent_ex_file=agent_ex_file_dir,
            infl_ex_file=infl_ex_file_dir,
            agent_state_out_file=agent_state_out_file_dir)
    # simultaneous update
    for selected_agent in agents_for_update:
        assert selected_agent.temp_new_state is not None
        selected_agent.set_state(selected_agent.temp_new_state)
        selected_agent.temp_new_state = None


def step(time_tick, network_of_agents):
    logger1.debug('STEP TIME TICK: %s', str(time_tick))

    logger1.debug('Begin random select and update network of agents')

    update_type = config.get('ModelParameters', 'UpdateType')

    if update_type == 'sequential':
        random_select_and_update(network_of_agents)
    elif update_type == 'simultaneous':
        update_simultaneous(network_of_agents,
                            config.getint(
                                'ModelParameters',
                                'NumberOfAgentsToUpdatePerTimeTick'))
    else:
        raise ValueError('Unknown simulation update type')

    # here = os.path.abspath(os.path.dirname(__file__))
    network_agent_step_time_dir = os.path.join(here, 'output',
                                               'network_of_agents.pout')

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

    generated_graph_dir = os.path.join(here, 'output', 'nx-generated.png')
    my_network.show_graph(generated_graph_dir)
    logger1.info('Generated graph saved in %s', generated_graph_dir)

    # here = os.path.abspath(os.path.dirname(__file__))
    # weight_in = here + '/WgtMakeM1.in'
    weight_in = here + config.get('LENSParameters', 'WeightInFile')
    # weight_dir = here + '/weights'
    weight_dir = here + config.get('LENSParameters', 'WeightsDirectory')

    network_of_agents = network_agent.NetworkAgent()
    fig_path = os.path.join(here, 'output', 'mann-generated.png')

    # TODO turn this into a function
    number_of_prototypes = config.getint('LENSParameters',
                                         'NumberOfPrototypes')
    prototype_generation = config.get('LENSParameters',
                                      'PrototypeGeneration')
    # if the prototype generation is the user, we will use the prototype
    # from the config file
    # else we will have the LensAgent Generate a random one
    if prototype_generation == 'user':
        prototypes_str = config.get('LENSParameters',
                                    'WeightBaseExample').split(';')
        prototypes = list(agent.LensAgent._str_to_int_list(s)
                          for s in prototypes_str)
        assert(isinstance(prototypes, list))
        assert(isinstance(prototypes[0], list))
        agent.LensAgent.prototypes = prototypes
        assert(isinstance(agent.LensAgent.prototypes, list))
    elif prototype_generation == 'random':
        num_units = config.getint('LENSParameters',
                                  'TotalNumberOfProcessingUnits')
        print(num_units)
        agent.LensAgent.set_lens_agent_prototypes(number_of_prototypes,
                                                  num_units)
        assert(isinstance(agent.LensAgent.prototypes, list))
        assert(isinstance(agent.LensAgent.prototypes[0], list))
        print('LensAgent prototype(s): ', str(agent.LensAgent.prototypes))
    else:
        raise ValueError("Unknown prototype generation algorithm")

    network_of_agents.create_multidigraph_of_agents_from_edge_list(
        n, my_network.G.edges_iter(),
        fig_path,
        agent_type=(config.get('NetworkParameters', 'AgentType'),
                    # TODO this interface should pass kwarg so it is more
                    # generalizable
                    config.getint('LENSParameters',
                                  'TotalNumberOfProcessingUnits')),
        weight_in_file=weight_in,
        weight_dir=weight_dir,
        base_example=config.get('LENSParameters', 'WeightBaseExample'),
        num_train_examples=config.getint('LENSParameters',
                                         'NumberOfWeightTrainExamples'),
        prototype_mutation_prob=config.getfloat(
            'LENSParameters', 'WeightTrainExampleMutationsProb'),
        training_criterion=config.getint('LENSParameters',
                                         'Criterion')
    )

    model_output = os.path.join(here, 'output',
                                config.get('General', 'ModelOutput'))
    # write all agent's init state (0's and None)
    network_of_agents.write_network_agent_step_info(
        -3, model_output, 'w')

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

    # prototype_string = config.get('LENSParameters', 'weightBaseExample')
    criterion = config.getint('LENSParameters', 'Criterion')
    epsilon = config.getfloat('LENSParameters', 'Epsilon')
    # seed agents who were select
    for selected_agent in agents_to_seed:
        # print("seeding: ",
        #       network_of_agents.G.nodes()[selected_agent.get_key()])
        logger1.info('Seeding agent  %s', str(selected_agent.get_key()))

        # print('pre-seed binary_state', selected_agent.binary_state)
        logger1.debug('Agent %s, pre-seed state: %s',
                      str(selected_agent.get_key()),
                      str(selected_agent.get_state()))

        # TODO REALLY HACKY CODE, the update/no_update function
        # since the prototypes are already set, we seed the agent with
        # using a prototype
        seed_list = selected_agent.prototype
        selected_agent.seed_agent_no_update(seed_list, epsilon)
        # write agent states to get the seeded value (without updating)
        network_of_agents.write_network_agent_step_info(
            -2, model_output, 'a')

        # since the prototypes are already set, we seed the agent with
        # using a prototype

        selected_agent.seed_agent_update(seed_list,
                                         lens_in_file_dir,
                                         agent_self_ex_file,
                                         agent_self_out_file,
                                         criterion, epsilon)

        logger1.debug('Agent %s seeded', str(selected_agent.get_key()))

        # print('post-seed_agent_binary_state', selected_agent.binary_state)
        logger1.debug('Agent %s, post-seed state: %s',
                      str(selected_agent.get_key()),
                      str(selected_agent.get_state()))

    # agent states after seed get updated
    network_of_agents.write_network_agent_step_info(
        -1, model_output, 'a')

    logger1.info('Begin steps')
    for i in range(config.getint('ModelParameters', 'NumberOfTimeTicks')):
        print("STEP # ", i)
        step(i, network_of_agents)

if __name__ == "__main__":
    main()

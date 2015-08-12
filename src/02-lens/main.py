#! /usr/bin/env python

import os
import logging
import configparser
# import random
# import warnings

import mann.network
import mann.network_agent
import mann.helper
import mann.lens_in_writer

# from mann import network
# from mann import network_agent
# from mann import helper
# from mann import lens_in_writer


# def deprecated(func):
#     """This is a decorator which can be used to mark functions
#     as deprecated. It will result in a warning being emmitted
#     when the function is used."""
#     def newFunc(*args, **kwargs):
#         warnings.warn("Call to deprecated function %s." % func.__name__,
#                       category=DeprecationWarning)
#         return func(*args, **kwargs)
#     newFunc.__name__ = func.__name__
#     newFunc.__doc__ = func.__doc__
#     newFunc.__dict__.update(func.__dict__)
#     return newFunc

HERE = os.path.abspath(os.path.dirname(__file__))


# set up logging to file - see previous section for more details
logging_format = '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
logging.basicConfig(level=logging.DEBUG,
                    format=logging_format,
                    datefmt='%m-%d %H:%M',
                    filename=os.path.join(HERE, 'output', 'myapp.log'),
                    filemode='w')

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)

formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')

# tell the handler to use this format
# set a format which is simpler for console use
console.setFormatter(formatter)

# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger. First the root..
logging.info('Logger created in main()')

# Now, define a couple of other loggers which might represent areas in your
# application:

logger1 = logging.getLogger(os.path.join(HERE, 'myapp.area1'))
logger2 = logging.getLogger(os.path.join(HERE, 'myapp.area2'))

# setting up the configparser
config = configparser.ConfigParser()
config.read(os.path.join(HERE, 'config.ini'))


# @deprecated
# def random_select_and_update(network_of_agents):
#     # randomly select nodes from network_of_agents
#     # select num_update number of the nodes for update
#     num_update = config.getint('ModelParameters',
#                                'NumberOfAgentsToUpdatePerTimeTick')
#     agents_for_update = network_of_agents.sample_network(num_update)
#     print('agents for update: ', agents_for_update)
#     print('key of agent for update')
#     print(network_of_agents.G.nodes()[agents_for_update[0].get_key()])

#     # update agents who were selected
#     for selected_agent in agents_for_update:
#         print("updating: ",
#               network_of_agents.G.nodes()[selected_agent.get_key()])

#         lens_in_file_dir = HERE + '/' + config.get('LENSParameters',
#                                                    'UpdateFromInflInFile')

#         agent_ex_file_dir = HERE + '/' + config.get('LENSParameters',
#                                                     'AgentExFile')

#         infl_ex_file_dir = HERE + '/' + config.get('LENSParameters',
#                                                    'InflExFile')

#         agent_state_out_file_dir = HERE + '/' + config.get('LENSParameters',
#                                                            'NewAgentStateFile')

#         selected_agent.update_agent_state(
#             'default',
#             lens_in_file=lens_in_file_dir,
#             agent_ex_file=agent_ex_file_dir,
#             infl_ex_file=infl_ex_file_dir,
#             agent_state_out_file=agent_state_out_file_dir)


# @deprecated
# def update_simultaneous(network_of_agents, num_agents_update):
#     """Simultaneously updates agents

#     :param network_of_agents: NetworkX graph of agents
#     :type network_of_agents: NetworkX graph

#     :parm num_agents_update: Number of agents that will be picked for update
#     :type num_agents_update: int

#     iterates through each node in the network and calculates a new state value
#     that will be saved to a temp variable.  It will then iterate though the
#     network again to update each node to the temp variable
#     """
#     agents_for_update = network_of_agents.sample_network(num_agents_update)
#     print('agents for update: ', agents_for_update)
#     print('key of agent for update')
#     for agent_update_key in agents_for_update:
#         print(network_of_agents.G.nodes()[agent_update_key.get_key()])

#     lens_in_file_dir = os.path.join(HERE, config.get('LENSParameters',
#                                                      'UpdateFromInflInFile'))
#     lens_in_file_dir = HERE + '/' + config.get('LENSParameters',
#                                                'UpdateFromInflInFile')

#     infl_ex_file_dir = os.path.join(HERE, config.get('LENSParameters',
#                                                      'InflExFile'))

#     agent_state_out_file_dir = os.path.join(HERE,
#                                             config.get('LENSParameters',
#                                                        'NewAgentStateFile'))

#     print('printing network_of_agents.G nodes')
#     for node in network_of_agents.G:
#         print(node)

#     # save to temp state before looping to sim update
#     lens_in_writer_helper = mann.lens_in_writer.LensInWriterHelper()
#     for selected_agent in agents_for_update:
#         print("updating: ",
#               network_of_agents.G.nodes()[selected_agent.get_key()])
#         print(selected_agent.temp_new_state)
#         assert selected_agent.temp_new_state is None

#         try:
#             random_predecessor_id = random.sample(selected_agent.predecessors,
#                                                   1)
#         except ValueError:
#             # if agent has no predecessor we skip it
#             continue
#         else:
#             predecessor_picked = random_predecessor_id[0]

#             print(type(predecessor_picked))

#             print(predecessor_picked)

#             write_str = lens_in_writer_helper.generate_lens_recurrent_attitude(
#                 mann.helper.convert_list_to_delim_str(selected_agent.state,
#                                                       delim=' '),
#                 mann.helper.convert_list_to_delim_str(predecessor_picked.state,
#                                                       delim=' '))
#             lens_in_writer_helper.write_in_file(infl_ex_file_dir, write_str)

#             print(lens_in_file_dir)
#             selected_agent.call_lens(lens_in_file_dir)

#             new_state_values = selected_agent.\
#                 get_new_state_values_from_out_file(
#                     agent_state_out_file_dir,
#                     'agent_type param is not used ... yet')
#             selected_agent.temp_new_state = new_state_values

#     # simultaneous update
#     for selected_agent in agents_for_update:
#         if len(selected_agent.predecessors) > 0:
#             assert (selected_agent.temp_new_state is not None)
#             selected_agent.state = selected_agent.temp_new_state
#             selected_agent.temp_new_state = None
#         else:
#             assert len(selected_agent.predecessors) == 0
#             warnings_str = "Pedecessors for Agent {}: {}".format(
#                 selected_agent.agent_id, selected_agent.predecessors)
#             warnings.warn(warnings_str)


def step(time_tick, network_of_agents, update_type, total_num_agents,
         model_output_path, agent_type, update_algorithm,
         lens_parameters):
    """Step function

    kwargs are used to pass in the intermediate LENS files used to call LENS
    and update the state

    :param time_tick: time tick
    :type time_tick: int

    :param network_of_agents: mann.network_agent.NetworkAgent class instance
    contains the NetworkX graph of agents
    :type network_of_agents: mann.network_agent.NetworkAgent

    :param update_type: 'simultaneous' or 'sequential' updating
    :type update_type: str

    :param total_num_agents: Total number of agents in the network
    :type total_num_agents: int

    :param model_output_path: path of where the simulation output goes
    :type model_output_path: str

    :param agent_type: LENS agent info
    :type agent_type: dict

    :param update_algorithm: 'random_1' or 'random_all'
    how should each agent choose its neighbours for updating
    :type update_algorithm: str

    :param lens_parameters: parameters used for LENS
    :type lens_parameters: dict
    """
    logger1.debug('STEP TIME TICK: %s', str(time_tick))

    logger1.debug('Begin random select and update network of agents')

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

    if update_type == 'sequential':
        # random_select_and_update(network_of_agents)
        network_of_agents.update_sequential(num_agent_update,
                                            update_algorithm,
                                            lens_parameters=lens_parameters)
    elif update_type == 'simultaneous':
        # TODO needs to be re-impemented
        print("Performing a simultaneous update.")
        update_simultaneous(network_of_agents,
                            config.getint(
                                'ModelParameters',
                                'NumberOfAgentsToUpdatePerTimeTick'))
    else:
        raise ValueError('Unknown simulation update type')

    network_agent_step_time_dir = os.path.join(HERE, 'output',
                                               'network_of_agents.pout')

    network_of_agents.write_network_agent_step_info(
        time_tick, network_agent_step_time_dir, 'a',
        agent_type.get("network_agent_type"),
        lens_agent_type=agent_type.get('lens_agent_type'))
    logger1.debug('Time ticks %s values appended to %s',
                  str(time_tick),
                  network_agent_step_time_dir)


def main():
    logger1.info('In main.main()')
    logger1.info('Starting Mulit Agent Neural Network (MANN)')

    # creating n number of agents
    n = config.getint('NetworkParameters', 'NumberOfAgents')
    logger1.debug('Number of agents to create: %s', str(n))

    network_type = config.get('NetworkParameters', 'GraphGenerator')
    if network_type == 'barabasi_albert_graph':
        m = config.getint('BarabasiAlbertGraph', 'm')
        logger1.debug('Number of edges to attach from a new node to existing'
                      'nodes: %s', str(m))
        my_network = mann.network.BidirectionalBarabasiAlbertGraph(n, m)
    elif network_type == 'watts_strogatz_graph':
        k = config.getint('WattsStrogatzGraph', 'k')
        p = config.getfloat('WattsStrogatzGraph', 'p')
        my_network = mann.network.WattsStrogatzGraph(n, k, p)
    elif network_type == 'fast_gnp_random_graph':
        p = config.getfloat('DirectedFastGNPRandomGraph', 'ProbEdgeCreation')
        logger1.debug('Probablity for edge creation: %s', str(p))
        my_network = mann.network.DirectedFastGNPRandomGraph(n, p)
    else:
        raise ValueError('unknown network type')

    # print("network edge list to copy\n", my_network.G.edges())  # edge list
    logger1.info('Network edge list to copy: %s', str(my_network.G.edges()))

    # print(my_network.G.edges_iter())

    generated_graph_dir = os.path.join(HERE, 'output', 'nx-generated.png')
    my_network.show_graph(generated_graph_dir)
    logger1.info('Generated graph saved in %s', generated_graph_dir)

    network_of_agents = mann.network_agent.NetworkAgent()
    fig_path = os.path.join(HERE, 'output', 'mann-generated.png')
    add_reverse_edge = config.getboolean('NetworkParameters', 'AddReverseEdge')

    agent_type = {
        "network_agent_type": config.get('ModelParameters', 'AgentType'),
        "lens_num_processing_units": config.getint(
            'LENSParameters', 'TotalNumberOfProcessingUnits'),
        "lens_agent_type": config.get('LENSParameters', 'AgentType')
    }

    network_of_agents.\
        create_multidigraph_of_agents_from_edge_list(
            n, my_network.G.edges_iter(),
            fig_path,
            agent_type=(agent_type.get("network_agent_type"),
                        agent_type.get("lens_num_processing_units"),
                        agent_type.get("lens_agent_type")),
            add_reverse_edge=add_reverse_edge
        )

    print('print network of agents:')

    print(len(network_of_agents.G))
    for node in network_of_agents.G:
        print(node)
        print(type(node))

    print(type(network_of_agents.G))

    model_output = os.path.join(HERE, 'output',
                                config.get('General', 'ModelOutput'))
    # write all agent's init state (0's and None)
    network_of_agents.write_network_agent_step_info(
        -3, model_output, 'w', agent_type.get("network_agent_type"),
        lens_agent_type=agent_type.get('lens_agent_type'))

    # make agents aware of predecessors
    # predecessors are agents who influence the current agent
    network_of_agents.set_predecessors_for_each_node()

    for node in network_of_agents.G:
        print(node)
        print(node.predecessors)

    # randomly select nodes from network_of_agents to seed
    num_seed = config.getint('ModelParameters', 'NumberOfAgentsToSeedOnInit')
    agents_to_seed = network_of_agents.sample_network(num_seed)
    # print("agents to seed: ", agents_to_seed)
    logger1.info('Agents seeded: %s', str(agents_to_seed))

    lens_in_file_dir = os.path.join(HERE,
                                    config.get('LENSParameters',
                                               'UpdateFromInflInFile'))

    agent_self_ex_file = os.path.join(HERE,
                                      config.get('LENSParameters',
                                                 'InflExFile'))

    agent_self_out_file = os.path.join(HERE,
                                       config.get('LENSParameters',
                                                  'NewAgentStateFile'))

    new_state_values_dict = {}
    types_of_inputs = {'all_neg': [0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
                       'all_pos': [1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
                       'amb_pos': [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
                       'amb_neg': [0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
                       'amb_good': [1, 1, 0, 0, 0, 1, 1, 0, 0, 0]}

    # seed agents who were select
    for selected_agent in agents_to_seed:
        logger1.info('Seeding agent  %s', str(selected_agent.get_key()))

        logger1.debug('Agent %s, pre-seed state: %s',
                      str(selected_agent.get_key()),
                      str(selected_agent.get_state()))

        network_of_agents.write_network_agent_step_info(
            -2, model_output, 'a', agent_type.get("network_agent_type"),
            lens_agent_type=agent_type.get('lens_agent_type'))

        lens_in_writer_helper = mann.lens_in_writer.LensInWriterHelper()
        write_str = lens_in_writer_helper.generate_lens_recurrent_attitude(
            mann.helper.convert_list_to_delim_str(selected_agent.state,
                                                  delim=' '),
            mann.helper.convert_list_to_delim_str(types_of_inputs['amb_good'],
                                                  delim=' '))
        lens_in_writer_helper.write_in_file(agent_self_ex_file, write_str)

        selected_agent.call_lens(lens_in_file_dir)

        new_state_values = selected_agent.get_new_state_values_from_out_file(
            os.path.join(agent_self_out_file))
        selected_agent.temp_new_state = new_state_values[:]
        new_state_values_dict[selected_agent.agent_id] = selected_agent.\
            temp_new_state

    print("SIMULTANEOUS UPDATE SEEDS")
    for selected_agent in agents_to_seed:
        selected_agent.state = new_state_values_dict[selected_agent.agent_id]
        selected_agent.temp_new_state = None

        logger1.debug('Agent %s seeded', str(selected_agent.get_key()))

        logger1.debug('Agent %s, post-seed state: %s',
                      str(selected_agent.agent_id),
                      str(selected_agent.state))

    # agent states after seed get updated
    network_of_agents.write_network_agent_step_info(
        -1, model_output, 'a', agent_type.get("network_agent_type"),
        lens_agent_type=agent_type.get('lens_agent_type'))

    logger1.info('Begin steps')

    print(network_of_agents.G.nodes())

    edge_list_file_dir = os.path.join(HERE, 'output', 'edge_list.gz')
    print(edge_list_file_dir)
    # network_of_agents.export_edge_list(edge_list_file_dir)
    network_of_agents.export_edge_list(edge_list_file_dir)

    model_output_path = os.path.join(
        HERE, 'output', config.get('General', 'ModelOutput'))

    total_num_agents = config.getint('NetworkParameters', 'NumberOfAgents')

    update_type = config.get('ModelParameters', 'UpdateType')

    update_algorithm = config.get('ModelParameters', 'UpdateAlgorithm')

    # these variables are copies from above... shouldn't be doing this
    lens_in_file_dir = lens_in_file_dir
    infl_ex_file_dir = agent_self_ex_file
    agent_state_out_file_dir = agent_self_out_file

    lens_parameters = {
        'in_file_path': lens_in_file_dir,
        'ex_file_path': infl_ex_file_dir,
        'new_state_path': agent_state_out_file_dir
    }

    for i in range(config.getint('ModelParameters', 'NumberOfTimeTicks')):
        print("STEP # ", i)
        step(i, network_of_agents, update_type, total_num_agents,
             model_output_path,
             agent_type=agent_type,
             update_algorithm=update_algorithm,
             lens_parameters=lens_parameters)

if __name__ == "__main__":
    main()

base_lens_dir = src/02-lens

.PHONY : help clean clean_02-lens single_sim copy_base_lens_dir

help :
	@echo "Please use \`make <target>\` where <target> is one of:"
	@echo "  single_sim      to setup a single experiment"
	@echo "  batch_sim       to setup a batch/sweep experiment (not implemented yet)"
	@echo "  clean           clean the directory (excluding results folder)"

clean : clean_02-lens

# rm the *.wt *.ex and *.out files in the base 02-lens directory
#    only .out should be here and Infl.ex
# rm the *.wt and .*ex files form the weights directory
clean_02-lens :
	@echo "cleaning base_lens_dir: $(base_lens_dir)"
# really hacky code to to ensure that there are files to delete
# which means that this target will succeed
	@touch ./$(base_lens_dir)/1.wt
	@touch ./$(base_lens_dir)/1.ex
	@touch ./$(base_lens_dir)/1.out
	@touch ./$(base_lens_dir)/weights/1.wt
	@touch ./$(base_lens_dir)/weights/1.ex

	@find ./$(base_lens_dir) -maxdepth 1 -type f -name '*.wt' -o -name '*.ex' -o -name '*.out' | xargs rm
	@find ./$(base_lens_dir)/weights -maxdepth 1 -type f -name '*.wt' -o -name '*.ex' | xargs rm


% :
	@echo "Unknown make target"
	make help

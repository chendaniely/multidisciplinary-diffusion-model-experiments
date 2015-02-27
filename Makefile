BASE_LENS_DIR = src/02-lens
SIM_RESULTS_DIR = results/simulations

.PHONY : help clean clean_02-lens clean_analysis single_sim copy_base_lens_dir

help :
	@echo "Please use \`make <target>\` where <target> is one of:"
	@echo "  single_sim      to setup a single experiment"
	@echo "  batch_sim       to setup a batch/sweep experiment (not implemented yet)"
	@echo "  clean           clean the directory (excluding results folder)"
	@echo "  analyze_single  generate analysis for single simulation"

clean : clean_02-lens clean_analysis

# rm the *.wt *.ex and *.out files in the base 02-lens directory
#    only .out should be here and Infl.ex
# rm the *.wt and .*ex files form the weights directory
clean_02-lens :
# really hacky code to to ensure that there are files to delete
# which means that this target will succeed
	@touch ./$(BASE_LENS_DIR)/1.wt
	@touch ./$(BASE_LENS_DIR)/1.ex
	@touch ./$(BASE_LENS_DIR)/1.out
	@touch ./$(BASE_LENS_DIR)/weights/1.wt
	@touch ./$(BASE_LENS_DIR)/weights/1.ex
	@touch ./$(BASE_LENS_DIR)/output/temp.filler

	@echo "cleaning dir: $(BASE_LENS_DIR)"
	@find ./$(BASE_LENS_DIR) -maxdepth 1 -type f -name '*.wt' -o -name '*.ex' -o -name '*.out' | xargs rm

	@echo "cleaning dir: $(BASE_LENS_DIR)/weights"
	@find ./$(BASE_LENS_DIR)/weights -maxdepth 1 -type f -name '*.wt' -o -name '*.ex' | xargs rm

	@echo "cleaning dir: $(BASE_LENS_DIR)/output"
	@find ./$(BASE_LENS_DIR)/output -maxdepth 1 -type f -not -name 'README.md' | xargs rm

clean_analysis :
	@echo "cleaning analysis output (mostly knitr .html files)"
	@touch src/1.html

	@find ./src -maxdepth 1 -type f -name '*.html' | xargs rm

single_sim : clean copy_base_lens_dir

copy_base_lens_dir :
# the eval is how you assign a variable in a recipe
# the shell is used to execute the next line as a shell command
	@echo "copying BASE_LENS_DIR to new_dir"
	$(eval new_dir = $(shell echo './results/simulations/02-lens_single_'`date +%Y-%m-%d_%H:%M:%S`))
	@echo $(new_dir)
	cp -r $(BASE_LENS_DIR) $(new_dir)

# folders that match single simulation pattern
SINGLE_SIM_OUTPUT_DIR = \
	$(shell find $(SIM_RESULTS_DIR) -maxdepth 1 -type d -name '*02-lens_single_*')

# append .html to end of the folder names (this is the generated analysis file)
SINGLE_SIM_OUTPUT_PATH = \
	$(addsuffix .html,$(SINGLE_SIM_OUTPUT_DIR))

SINGLE_SIM_OUTPUT_FILE = \
	$(notdir $(SINGLE_SIM_OUTPUT_PATH))

%02-lens_single_%.html : src/analysis.Rmd
	cd $(dir $<) && \
	Rscript -e "config_from_makefile <- TRUE; \
		config_make_batch_folder_path <- ../results/simulations/$$(basename $<) \
		config_make_name_batch_simulation_output_folder <- $$(basename $<) \
		rmarkdown::render('$$(basename $<)', \
				  output = '$$(basename $@)')"

analyze_single :
	@for HTML_OUTPUT_FILE in $(SINGLE_SIM_OUTPUT_PATH) ; do \
		echo $$HTML_OUTPUT_FILE ; \
		if [ -e $$HTML_OUTPUT_FILE ] ; \
		then \
			echo 'file exists' ; \
			if [ "`stat --format %Y src/analysis.Rmd`" -gt "`stat --format %Y $$HTML_OUTPUT_FILE`" ] ; \
			then \
				echo 'needs updating... updating now...' ; \
				Rscript -e "str <- 'updating in R'; \
                                            print(str); \
                                            f <- '$$HTML_OUTPUT_FILE'; \
                                            print(f); \
\
                                            config_from_makefile <- TRUE; \
\
                                            config_make_batch_folder_path <- stringr::str_replace(f, '.html', ''); \
                                            config_make_batch_folder_path <- paste0('../', config_make_batch_folder_path); \
                                            print(config_make_batch_folder_path) ; \
\
                                            config_make_name_batch_simulation_output_folder <- \
                                                stringr::str_replace(config_make_batch_folder_path, 'results\\\/simulations\\\/', ''); \
                                            print(config_make_name_batch_simulation_output_folder); \
                                            rmarkdown::render('src/analysis.Rmd', output_file = f, output_dir = '../results/simulations'); \
\
                                            " ; \
			fi ; \
		else \
			echo 'file does not exist... creating now...' ; \
				Rscript -e "str <- 'updating in R'; \
                                            print(str); \
                                            f <- '$$HTML_OUTPUT_FILE'; \
                                            print(f); \
\
                                            config_from_makefile <- TRUE; \
\
                                            config_make_batch_folder_path <- stringr::str_replace(f, '.html', ''); \
                                            config_make_batch_folder_path <- paste0('../', config_make_batch_folder_path); \
                                            print(config_make_batch_folder_path) ; \
\
                                            config_make_name_batch_simulation_output_folder <- \
                                                stringr::str_replace(config_make_batch_folder_path, 'results\\\/simulations\\\/', ''); \
                                            print(config_make_name_batch_simulation_output_folder); \
                                            rmarkdown::render('src/analysis.Rmd', output_file = f, output_dir = '../results/simulations'); \
\
                                            " ; \
		fi ; \
		echo "==========" ; \
	done


% :
	@echo "Unknown make target"
	make help

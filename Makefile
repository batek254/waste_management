#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = waste_management
ENV_NAME_TF = waste_management_tf
PYTHON_VERSION = 3.11
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################


## Install Python Dependencies
.PHONY: requirements
requirements:
ifeq ($(shell basename $(CONDA_PREFIX)), waste_management)
	conda env update --name $(PROJECT_NAME) --file environment.yml --prune
else ifeq ($(shell basename $(CONDA_PREFIX)), waste_management_tf)
	conda env update --name $(ENV_NAME_TF) --file environment_tf.yml --prune
else
	@echo ">>> No conda environment found. Please create one using 'make create_environment'"
endif
	

## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8 and black (use `make format` to do formatting)
.PHONY: lint
lint:
	flake8 waste_management
	isort --check --diff --profile black waste_management
	black --check --config pyproject.toml waste_management

## Format source code with black
.PHONY: format
format:
	black --config pyproject.toml waste_management


## Download Data from storage system
.PHONY: sync_data_down
sync_data_down:
	az storage blob download-batch -s app-container/data/ \
		-d data/
	

## Upload Data to storage system
.PHONY: sync_data_up
sync_data_up:
	az storage blob upload-batch -d app-container/data/ \
		-s data/
	



## Set up python interpreter environment
.PHONY: create_environment
create_environment:
	@echo ">>> embedded environment will be created and libmamba solver will be set as default solver"
	conda install -n base conda-libmamba-solver
	conda config --set solver libmamba
	conda env create --name $(PROJECT_NAME) -f environment.yml
	@echo ">>> conda env created. Activate with:\nconda activate $(PROJECT_NAME)"


# Set up python interpreter environment for tensorflow
.PHONY: create_environment_tf
create_environment_tf:
	@echo ">>> tf environment will be created and libmamba solver will be set as default solver"
	conda install -n base conda-libmamba-solver
	conda config --set solver libmamba
	conda env create --name $(ENV_NAME_TF) -f environment_tf.yml
	@echo ">>> conda env created. Activate with:\nconda activate $(ENV_NAME_TF)"



#################################################################################
# PROJECT RULES                                                                 #
#################################################################################


## Make Dataset
.PHONY: data
data: requirements
	$(PYTHON_INTERPRETER) waste_management/dataset.py


#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)

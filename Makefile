# Makefile

LATEX_SERVICE = latex
APP_SERVICE = app
COMPOSE_FILE = docker-compose/docker-compose.yml

OUTDIR = build-latex

.PHONY: build-latex build-app compile-latex compile-chapter clean-latex run-app test-app docs

build-latex:
	docker compose -f $(COMPOSE_FILE) build $(LATEX_SERVICE)

build-app:
	docker compose -f $(COMPOSE_FILE) build $(APP_SERVICE)

compile-latex: build-latex
	docker compose -f $(COMPOSE_FILE) run --rm $(LATEX_SERVICE) \
	  latexmk -pdf -xelatex -interaction=nonstopmode \
	  -outdir=$(OUTDIR) \
	  thesis/main/main.tex

compile-chapter: build-latex
# Użycie: make compile-chapter CHAP=thesis/chapters/wprowadzenie.tex
ifndef CHAP
	$(error Użycie: make compile-chapter CHAP=thesis/chapters/rozdzial.tex)
endif
	docker compose -f $(COMPOSE_FILE) run --rm $(LATEX_SERVICE) \
	  latexmk -pdf -xelatex -interaction=nonstopmode \
	  -outdir=$(OUTDIR) \
	  $(CHAP)

clean-latex: build-latex
	docker compose -f $(COMPOSE_FILE) run --rm $(LATEX_SERVICE) \
	  bash -c "rm -rf $(OUTDIR)/*"

run-app: build-app
# Przykład: uruchomienie pliku Python
	docker compose -f $(COMPOSE_FILE) run --rm $(APP_SERVICE) \
	  python3 code/python/main.py

test-app: build-app
# Przykład testu w C
	docker compose -f $(COMPOSE_FILE) run --rm $(APP_SERVICE) \
	  bash -c "cd code/c && make test"

docs: build-app
# Generowanie dokumentacji Doxygen
	docker compose -f $(COMPOSE_FILE) run --rm $(APP_SERVICE) \
	  doxygen docs/doxygen/Doxyfile

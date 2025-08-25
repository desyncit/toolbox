CC = gcc
CFLAGS = -g -std=c99 -Wall -pedantic
CXXFLAGS = -lstdc++
INCDIR = include
SRCDIR = src
OUTDIR = bin

CSRCS = $(wildcard $(SRCDIR)/*.c)
CXXSRCS = $(wildcard $(SRCDIR)/*.cpp)

CTARGETS = $(patsubst $(SRCDIR)/%.c,%,$(CSRCS))
CXXTARGETS = $(patsubst $(SRCDIR)/%.cpp,%,$(CXXSRCS))

all: $(CTARGETS) $(CXXTARGETS)

%: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -I$(INCDIR) $< -o $(OUTDIR)/$@

%: $(SRCDIR)/%.cpp
	$(CC) $(CXXFLAGS) $< -o $(OUTDIR)/$@

.PHONY: clean
clean:
	rm $(OUTDIR)/*

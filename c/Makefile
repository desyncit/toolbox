CC = gcc
CFLAGS = -std=c99 -Wall -g -pedantic -O3
INCDIR = include
SRCDIR = src
OUTDIR = bin

SRCS = $(wildcard $(SRCDIR)/*.c)
TARGETS = $(patsubst $(SRCDIR)/%.c,%,$(SRCS))

all: $(TARGETS)

%: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -I$(INCDIR) $< -o $(OUTDIR)/$@

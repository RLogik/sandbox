#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IMPORTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

from src.local.maths import *;
from src.local.misc import *;
from src.local.system import *;
from src.local.typing import *;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GLOBAL VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# METHODS: cli
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def getCliArgs(*args: str) -> Tuple[List[str], Dict[str, Any]]:
    tokens = [];
    kwargs = {};
    N = len(args);
    indexes = [ i for i, arg in enumerate(args) if re.match(r'^\-+', arg) ];
    notindexes = [ i for i, _ in enumerate(args) if not (i in indexes) ];
    i = 0;
    while i < N:
        if i in indexes and i+1 in notindexes:
            key = re.sub(r'^\-*', '', args[i]).lower();
            value = args[i+1];
            kwargs[key] = value;
            i += 2;
            continue;
        m = re.match(r'^-*(.*?)\=(.*)$', args[i]);
        if m:
            key = re.sub(r'^\-*', '', m.group(1)).lower();
            value = m.group(2);
            kwargs[key] = value;
        else:
            arg = re.sub(r'^\-*', '', args[i]).lower();
            tokens.append(arg);
        i += 1;
    return tokens, kwargs;

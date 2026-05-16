import torch

import ntops
from ntops.torch.utils import _cached_make


def __OP_NAME__(input, other, *, out=None):
    if out is None:
        out = torch.empty_like(input)

    kernel = _cached_make(ntops.kernels.__OP_NAME__.premake, input.ndim)
    kernel(input, other, out)
    return out


import torch

import ntops
from ntops.torch.utils import _cached_make


def __OP_NAME__(input, dim=-1, keepdim=False, *, out=None):
    if keepdim:
        raise AssertionError("keepdim=True is not supported by this template yet.")

    dim = dim if dim >= 0 else dim + input.ndim

    if out is None:
        out_shape = input.shape[:dim] + input.shape[dim + 1 :]
        out = torch.empty(out_shape, dtype=input.dtype, device=input.device)

    kernel = _cached_make(ntops.kernels.__OP_NAME__.premake, input.ndim, dim=dim)
    kernel(input, out)
    return out

import functools

import ninetoothed.language as ntl
from ninetoothed import Tensor

from ntops.kernels.reduction import arrangement


def application(input, output):
    # Replace `sum` with the target reduction.
    output = ntl.sum(input, -1)  # noqa: F841


def premake(ndim, dim=-1, dtype=None, block_size=None):
    arrangement_ = functools.partial(arrangement, dim=dim, block_size=block_size)
    output_ndim = ndim - 1
    tensors = (Tensor(ndim, dtype=dtype), Tensor(output_ndim, dtype=dtype))
    return arrangement_, application, tensors


import pytest
import torch

import ntops
from tests.skippers import skip_if_cuda_not_available
from tests.utils import generate_arguments


@skip_if_cuda_not_available
@pytest.mark.parametrize("dim", (-1,))
@pytest.mark.parametrize(*generate_arguments())
def test___OP_NAME__(shape, dim, dtype, device, rtol, atol):
    if len(shape) == 0:
        pytest.skip("scalar reduction is not covered by this template")

    input = torch.randn(shape, dtype=dtype, device=device)

    ninetoothed_output = ntops.torch.__OP_NAME__(input, dim=dim)
    reference_output = torch.__OP_NAME__(input, dim=dim)

    assert torch.allclose(ninetoothed_output, reference_output, rtol=rtol, atol=atol)


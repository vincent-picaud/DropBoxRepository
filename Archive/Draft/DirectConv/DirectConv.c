#include <math.h>
#include <stdlib.h>
#include <assert.h>

#define SCALAR double

struct Omega
{
    int l, u;
};

void scale(struct Omega* lambda_omega, const int lambda, const struct Omega omega)
{
    assert(lambda);

    if(lambda > 0)
    {
        lambda_omega->l = lambda * omega.l;
        lambda_omega->u = lambda * omega.u;
    }
    else
    {
        lambda_omega->l = lambda * omega.u;
        lambda_omega->u = lambda * omega.l;
    }
}

void compute_omegaGamma1(struct Omega* omegaGamma1, const struct Omega omegaAlpha, const int lambda,
                         const struct Omega omegaBeta)
{
    struct Omega lambda_omegaAlpha;

    scale(&lambda_omegaAlpha, lambda, omegaAlpha);

    omegaGamma1->l = omegaBeta.l - lambda_omegaAlpha.l;
    omegaGamma1->u = omegaBeta.u - lambda_omegaAlpha.u;
}

int imin(const int a, const int b) { return a < b ? a : b; };
int imax(const int a, const int b) { return a > b ? a : b; };

void relativeComplement_left(struct Omega* omega_left, const struct Omega A, const struct Omega B)
{
    omega_left->l = A.l;
    omega_left->u = imin(A.u, B.l - 1);
}

void relativeComplement_right(struct Omega* omega_right, const struct Omega A, const struct Omega B)
{
    omega_right->l = imax(A.l, B.u + 1);
    omega_right->u = A.u;
}

typedef SCALAR (*BoundaryExtension)(const int size, const SCALAR* p, const int stride, const int k);

SCALAR boundaryExtension_zeroPadding(const int size, const SCALAR* p, const int stride, const int k)
{
    return (k >= 0) && (k < size) ? p[k * stride] : 0;
}

SCALAR boundaryExtension_constant(const int size, const SCALAR* p, const int stride, const int k)
{
    return (k < 0) ? p[0] : (k < size ? p[k * stride] : p[(size - 1) * stride]);
}

int Fmod(const int D, const int d)
{
    assert(d);

    int r = D % d;
    if((r > 0 && d < 0) || (r < 0 && d > 0)) r = r + d;
    return r;
}

SCALAR boundaryExtension_periodic(const int size, const SCALAR* p, const int stride, const int k)
{
    const int offset = Fmod(k, size);
    assert((offset >= 0) && (offset < size));

    return p[offset * stride];
}

SCALAR boundaryExtension_mirror(const int size, const SCALAR* p, const int stride, const int k)
{
    const int offset = size - 1 - abs(size - 1 - Fmod(k, 2 * (size - 1)));
    assert((offset >= 0) && (offset < size));

    return p[offset * stride];
}

enum BoundaryExtensionEnum
{
    BoundaryExtensionEnum_ZeroPadding = 0,
    BoundaryExtensionEnum_Constant,
    BoundaryExtensionEnum_Periodic,
    BoundaryExtensionEnum_Mirror,
    BoundaryExtensionEnum_END
};

BoundaryExtension boundaryExtension[BoundaryExtensionEnum_END] = {boundaryExtension_zeroPadding,
                                                                  boundaryExtension_constant,
                                                                  boundaryExtension_periodic, boundaryExtension_mirror};

void direct_conv(const SCALAR* alpha, const int alphaStride, const struct Omega omegaAlpha, const int lambda,
                 const SCALAR* beta, const int betaStride, const int betaSize, const SCALAR* gamma,
                 const int gammaStride, const struct Omega omegaBeta, enum BoundaryExtensionEnum leftBoundary,
                 enum BoundaryExtensionEnum rightBoundary)
{
  
}

int main() {}

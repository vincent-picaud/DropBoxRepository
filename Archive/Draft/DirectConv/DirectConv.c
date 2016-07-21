#include <math.h>
#include <stdlib.h>
#include <assert.h>

#define SCALAR double

int imin(const int a, const int b) { return a < b ? a : b; };
int imax(const int a, const int b) { return a > b ? a : b; };

struct Omega
{
    int l, u;
};

int length(const struct Omega omega) { return omega.u - omega.l + 1; }

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

void compute_omegaGamma_1(struct Omega* omegaGamma_1, const struct Omega omegaAlpha, const int lambda,
                          const struct Omega omegaBeta)
{
    struct Omega lambda_omegaAlpha;

    scale(&lambda_omegaAlpha, lambda, omegaAlpha);

    omegaGamma_1->l = omegaBeta.l - lambda_omegaAlpha.l;
    omegaGamma_1->u = omegaBeta.u - lambda_omegaAlpha.u;
}

void intersect(struct Omega* A_cup_B, const struct Omega A, const struct Omega B)
{
    A_cup_B->l = imax(A.l, B.l);
    A_cup_B->u = imin(A.u, B.u);
}

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

int modFloored(const int D, const int d)
{
    assert(d);

    int r = fmod(D, d);
    if((r > 0 && d < 0) || (r < 0 && d > 0)) r = r + d;
    return r;
}

SCALAR boundaryExtension_periodic(const int size, const SCALAR* p, const int stride, const int k)
{
    const int offset = modFloored(k, size);
    assert((offset >= 0) && (offset < size));

    return p[offset * stride];
}

SCALAR
boundaryExtension_mirror(const int size, const SCALAR* p, const int stride, const int k)
{
    const int offset = size - 1 - abs(size - 1 - modFloored(k, 2 * (size - 1)));
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

void direct_conv(const SCALAR* tilde_alpha, const int alphaStride, const struct Omega omegaAlpha, const int lambda,
                 const SCALAR* beta, const int betaStride, const int betaSize, SCALAR* gamma, const int gammaStride,
                 const struct Omega omegaGamma, enum BoundaryExtensionEnum leftBoundary,
                 enum BoundaryExtensionEnum rightBoundary)
{
    assert(lambda);

    const struct Omega omegaBeta = {0, betaSize - 1};

    const struct Omega omegaTildeAlpha = {0, length(omegaAlpha) - 1};

    for(int i = omegaGamma.l; i <= omegaGamma.u; i++)
    {
        gamma[i * gammaStride] = 0;
    }

    struct Omega omegaGamma_1, restrictOmegaGamma_1;
    compute_omegaGamma_1(&omegaGamma_1, omegaAlpha, lambda, omegaBeta);
    intersect(&restrictOmegaGamma_1, omegaGamma, omegaGamma_1);

    const int beta_offset = lambda * omegaAlpha.l;

#pragma omp simd
    for(int k = restrictOmegaGamma_1.l; k <= restrictOmegaGamma_1.u; k++)
    {
        for(int i = omegaTildeAlpha.l; i <= omegaTildeAlpha.u; i++)
        {
            gamma[i * gammaStride] += tilde_alpha[i * alphaStride] * beta[(k + lambda * i + beta_offset) * betaStride];
        }
    }

    struct Omega restrictOmegaGamma_1_left;
    relativeComplement_left(&restrictOmegaGamma_1_left, omegaGamma, restrictOmegaGamma_1);
    assert((leftBoundary >= 0) && (leftBoundary < BoundaryExtensionEnum_END));
    const BoundaryExtension Phi_left = boundaryExtension[leftBoundary];

#pragma omp simd
    for(int k = restrictOmegaGamma_1_left.l; k <= restrictOmegaGamma_1_left.u; k++)
    {
        for(int i = omegaTildeAlpha.l; i <= omegaTildeAlpha.u; i++)
        {
            gamma[i * gammaStride] +=
                tilde_alpha[i * alphaStride] * Phi_left(betaSize, beta, betaStride, k + lambda * i + beta_offset);
        }
    }

    struct Omega restrictOmegaGamma_1_right;
    relativeComplement_right(&restrictOmegaGamma_1_right, omegaGamma, restrictOmegaGamma_1);
    assert((rightBoundary >= 0) && (rightBoundary < BoundaryExtensionEnum_END));
    const BoundaryExtension Phi_right = boundaryExtension[rightBoundary];

#pragma omp simd
    for(int k = restrictOmegaGamma_1_right.l; k <= restrictOmegaGamma_1_right.u; k++)
    {
        for(int i = omegaTildeAlpha.l; i <= omegaTildeAlpha.u; i++)
        {
            gamma[i * gammaStride] +=
                tilde_alpha[i * alphaStride] * Phi_right(betaSize, beta, betaStride, k + lambda * i + beta_offset);
        }
    }
}

int main()
{

    const struct Omega omegaAlpha = {-2, 0};
    SCALAR tilde_alpha[3] = {0, 0, 1};
    assert(length(omegaAlpha) == 3);
    const int alphaStride = 1;

    const int lambda = 1;

    SCALAR beta[10];
    for(int i = 0; i < 10; i++)
    {
        beta[i] = i;
    }
    const int betaStride = 1;
    const int betaSize = 10;

    SCALAR gamma[20];
    const int gammaStride = 1;
    struct Omega omegaGamma = {0, 19};

    const enum BoundaryExtensionEnum leftBoundary = BoundaryExtensionEnum_Mirror;
    const enum BoundaryExtensionEnum rightBoundary = BoundaryExtensionEnum_Periodic;

    direct_conv(tilde_alpha, alphaStride, omegaAlpha, lambda, beta, betaStride, betaSize, gamma, gammaStride,
                omegaGamma, leftBoundary, rightBoundary);
}

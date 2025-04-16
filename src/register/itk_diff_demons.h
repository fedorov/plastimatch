/* -----------------------------------------------------------------------
   See COPYRIGHT.TXT and LICENSE.TXT for copyright and license information
   ----------------------------------------------------------------------- */
#ifndef _itk_diff_demons_h_
#define _itk_diff_demons_h_

#if PLM_USE_NEW_ITK_DEMONS
#include "itkDiffeomorphicDemonsRegistrationFilter.h"
#else
#include "itkDiffeomorphicDemonsRegistrationWithMaskFilter.h"
#endif
#include <itk_demons_registration_filter.h>

class itk_diffeomorphic_demons_filter: public itk_demons_registration_filter
{

#if PLM_USE_NEW_ITK_DEMONS
    typedef itk::DiffeomorphicDemonsRegistrationFilter<
        FloatImageType,
        FloatImageType,
        DeformationFieldType> DiffeomorphicDemonsFilterType;
#else
    typedef itk::DiffeomorphicDemonsRegistrationWithMaskFilter<
        FloatImageType,
        FloatImageType,
        DeformationFieldType> DiffeomorphicDemonsFilterType;
#endif

    typedef DiffeomorphicDemonsFilterType::DemonsRegistrationFunctionType DiffeomorphicDemonsFunctionType;

    typedef DiffeomorphicDemonsFilterType::GradientType GradientType;

public:
    itk_diffeomorphic_demons_filter();
    ~itk_diffeomorphic_demons_filter();
    void update_specific_parameters(const Stage_parms* stage);
};

#endif

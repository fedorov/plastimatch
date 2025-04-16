/* -----------------------------------------------------------------------
   See COPYRIGHT.TXT and LICENSE.TXT for copyright and license information
   ----------------------------------------------------------------------- */
#ifndef itk_demons_types_h
#define itk_demons_types_h

#include "plmregister_config.h"
#include "itk_image_type.h"

#if PLM_USE_NEW_ITK_DEMONS
#include "itkPDEDeformableRegistrationFilter.h"
#include "itkPDEDeformableRegistrationFunction.h"
#else
#include "itkLogDomainDemonsRegistrationFilterWithMaskExtension.h"
#include "itkSymmetricLogDomainDemonsRegistrationFilterWithMaskExtension.h"
#include "itkPDEDeformableRegistrationWithMaskFilter.h"
#endif

#if PLM_USE_NEW_ITK_DEMONS
typedef itk::PDEDeformableRegistrationFilter<
    FloatImageType,
    FloatImageType,DeformationFieldType>  PDEDeformableRegistrationFilterType;
typedef itk::PDEDeformableRegistrationFunction<
    FloatImageType,
    FloatImageType,DeformationFieldType>  PDEDeformableRegistrationFunctionType;
#else
typedef itk::PDEDeformableRegistrationWithMaskFilter<
    FloatImageType,
    FloatImageType,DeformationFieldType>  PDEDeformableRegistrationFilterType;
typedef itk::LogDomainDemonsRegistrationFilterWithMaskExtension<
    FloatImageType,
    FloatImageType,
    DeformationFieldType> LogDomainDemonsFilterType;
typedef itk::SymmetricLogDomainDemonsRegistrationFilterWithMaskExtension<
    FloatImageType,
    FloatImageType,
    DeformationFieldType> SymmetricLogDomainDemonsFilterType;
#endif

#endif

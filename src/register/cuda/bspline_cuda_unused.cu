// JAS 2010.11.13
// waiting for the cpu to generate large vector fields after a super fast
// gpu driven registration was too troublesome.  this stub function is called
// in the exact same fashion as the cpu equivalent, but is faster. ^_~

// GCS FIX: This function seems not to be used.  We can upgrade it to use
// the new texture API when we have time.
#if defined (commentout)
void
CUDA_bspline_interpolate_vf (
    Volume* interp,
    Bspline_xform* bxf
)
{
    dim3 dimGrid;
    dim3 dimBlock;

    // Coefficient LUT
    // N.b. we can't use build_coeff_lut() because we don't have a dev_ptrs
    // ----------------------------------------------------------
    Cuda_texture tex_coeff;
    plm_long coeff_size = sizeof(float) * bxf->num_coeff;
    tex_coeff.make_and_bind (&coeff_size, bxf->coeff);
    CUDA_check_error("Failed to bind dev_ptrs->coeff to texture reference!");


    // Build B-spline LUTs & attach to textures
    // ----------------------------------------------------------
    plm_long LUT_Bspline_x_size = 4*bxf->vox_per_rgn[0]* sizeof(float);
    plm_long LUT_Bspline_y_size = 4*bxf->vox_per_rgn[1]* sizeof(float);
    plm_long LUT_Bspline_z_size = 4*bxf->vox_per_rgn[2]* sizeof(float);

    float* LUT_Bspline_x_cpu = (float*)malloc(LUT_Bspline_x_size);
    float* LUT_Bspline_y_cpu = (float*)malloc(LUT_Bspline_y_size);
    float* LUT_Bspline_z_cpu = (float*)malloc(LUT_Bspline_z_size);

    for (int j = 0; j < 4; j++)
    {
        for (int i = 0; i < bxf->vox_per_rgn[0]; i++) {
            LUT_Bspline_x_cpu[j*bxf->vox_per_rgn[0] + i] =
                CPU_obtain_bspline_basis_function (j, i, bxf->vox_per_rgn[0]);
        }

        for (int i = 0; i < bxf->vox_per_rgn[1]; i++) {
            LUT_Bspline_y_cpu[j*bxf->vox_per_rgn[1] + i] =
                CPU_obtain_bspline_basis_function (j, i, bxf->vox_per_rgn[1]);
        }

        for (int i = 0; i < bxf->vox_per_rgn[2]; i++) {
            LUT_Bspline_z_cpu[j*bxf->vox_per_rgn[2] + i] =
                CPU_obtain_bspline_basis_function (j, i, bxf->vox_per_rgn[2]);
        }
    }

    float *LUT_Bspline_x, *LUT_Bspline_y, *LUT_Bspline_z;

    CUDA_alloc_copy ((void **)&LUT_Bspline_x,
                     (void **)&LUT_Bspline_x_cpu,
                     LUT_Bspline_x_size);

    cudaBindTexture(0, lut_bspline_x, LUT_Bspline_x, LUT_Bspline_x_size);

    CUDA_alloc_copy ((void **)&LUT_Bspline_y,
                     (void **)&LUT_Bspline_y_cpu,
                     LUT_Bspline_y_size);

    cudaBindTexture(0, lut_bspline_y, LUT_Bspline_y, LUT_Bspline_y_size);

    CUDA_alloc_copy ((void **)&LUT_Bspline_z,
                     (void **)&LUT_Bspline_z_cpu,
                     LUT_Bspline_z_size);

    cudaBindTexture(0, lut_bspline_z, LUT_Bspline_z, LUT_Bspline_z_size);

    free (LUT_Bspline_x_cpu);
    free (LUT_Bspline_y_cpu);
    free (LUT_Bspline_z_cpu);


    // Get things ready for the kernel
    // ---------------------------------------------------------------
    int3 vol_dim, rdim, cdim, vpr;
    CUDA_array2vec_int3 (&vol_dim, interp->dim);
    CUDA_array2vec_int3 (&rdim, bxf->rdims);
    CUDA_array2vec_int3 (&cdim, bxf->cdims);
    CUDA_array2vec_int3 (&vpr, bxf->vox_per_rgn);

    plm_long vf_size = interp->npix * 3*sizeof(float);



    // Kernel setup & execution
    // ---------------------------------------------------------------
    int num_blocks = 
    CUDA_exec_conf_1tpe (
        &dimGrid,          // OUTPUT: Grid  dimensions
        &dimBlock,         // OUTPUT: Block dimensions
        interp->npix,      // INPUT: Total # of threads
        192,               // INPUT: Threads per block
        true);             // INPUT: Is threads per block negotiable?

    int tpb = dimBlock.x * dimBlock.y * dimBlock.z;

    size_t sMemSize = tpb * 3*sizeof(float);
    size_t vf_gpu_size = sMemSize * num_blocks;

    float* vf_gpu;
    CUDA_alloc_zero ((void**)&vf_gpu, vf_gpu_size, cudaAllocStern);

    kernel_bspline_interpolate_vf <<<dimGrid, dimBlock, sMemSize>>> (
            vf_gpu,     // out
            vol_dim,    // in
            rdim,       // in
            cdim,       // in
            vpr         // in
    );

    cudaDeviceSynchronize();
    CUDA_check_error("kernel_bspline_interpolate_vf()");

    // notice that we don't copy the "garbage" at the end of gpu memory
    cudaMemcpy(interp->img, vf_gpu, vf_size, cudaMemcpyDeviceToHost);
    CUDA_check_error("error copying vf back to CPU");


    // Clean up
    // ---------------------------------------------------------------
    cudaUnbindTexture(tex_coeff);
    cudaUnbindTexture(lut_bspline_x);
    cudaUnbindTexture(lut_bspline_y);
    cudaUnbindTexture(lut_bspline_z);

    cudaFree(vf_gpu);
    cudaFree(coeff);
    cudaFree(LUT_Bspline_x);
    cudaFree(LUT_Bspline_y);
    cudaFree(LUT_Bspline_z);
}
#endif




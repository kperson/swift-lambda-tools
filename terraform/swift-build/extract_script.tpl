mkdir -p  ${tag}  \
&& docker run --rm -v ${working_dir}/${tag}:/my_export_out ${dind_mount} ${tag} cp ${container_file} /my_export_out/${output_file} \
&& docker rmi ${tag} \
&& cp ${bootstrap_file} ${tag} \
&& chmod +x ${tag}/bootstrap  \

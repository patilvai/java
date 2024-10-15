
aws_eks_cluster_config = {

      "eks_cluster" = {

        eks_cluster_name         = "eks_cluster"
        eks_subnet_ids = ["subnet-06f6429ef74be23d6","subnet-03109b40a02681959","subnet-0317f286839e0f522"]
        tags = {
             "Name" =  "eks_cluster"
         }  
      }
}

eks_node_group_config = {

  "node1" = {

        eks_cluster_name         = "eks_cluster"
        node_group_name          = "mynode"
        nodes_iam_role           = "Node_instance"
        node_subnet_ids          = ["subnet-06f6429ef74be23d6","subnet-03109b40a02681959","subnet-0317f286839e0f522"]

        tags = {
             "Name" =  "node1"
         } 
  }
}

provider "google" {
  credentials = "${file("voxxed-27a2e4eec660.json")}"
  project     = "voxxed-198802"
}

resource "google_compute_instance" "default" {
  zone = "us-west1-a"
  name = "tf-compute-1"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}

output "instance_id" {
  value = "${google_compute_instance.default.self_link}"
}
